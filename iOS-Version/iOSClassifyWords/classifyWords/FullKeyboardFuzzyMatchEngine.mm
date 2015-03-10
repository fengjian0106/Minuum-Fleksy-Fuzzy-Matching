//
//  FullKeyboardFuzzyMatchEngine.m
//  classifyWords
//
//  Created by fengjian on 15/2/3.
//  Copyright (c) 2015年 ziipin. All rights reserved.
//

#import "FullKeyboardFuzzyMatchEngine.h"
#import "BNRTimeBlock.h"
#import "NSFileHandle+KBAdditions.h"

#import "KDTreeVectorOfVectorsAdaptor.hpp"
//#include "nanoflann.hpp"

#include "msgpack-c-change-version/msgpack.hpp"
#include <string>



//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
typedef std::vector<std::vector<float> > fullKeyboardWordsMatrix;
typedef KDTreeVectorOfVectorsAdaptor<fullKeyboardWordsMatrix, float> fullKeyboardKDTree;
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////



@interface FullKeyboardFuzzyMatchEngine ()
@property (nonatomic, strong) NSDictionary *fullKeyboardEncodeDict;
@property (nonatomic, strong) NSMutableArray *fullKeyboardDecodeDict;

@property (nonatomic, assign) NSInteger maxLength;
//!! whthin init() func, can not use self.fullKeyboardWordsMatrixList, only can use _fullKeyboardWordsMatrixList !!
@property (nonatomic, assign) std::vector<std::shared_ptr<fullKeyboardWordsMatrix> > fullKeyboardWordsMatrixList;
@property (nonatomic, assign) std::vector<std::shared_ptr<fullKeyboardKDTree> > fullKeyboardKDTreeList;
@end

@implementation FullKeyboardFuzzyMatchEngine
- (void)initEncodeAndDecodeDict {
  //http://www.onevcat.com/2012/06/modern-objective-c/
  self.fullKeyboardEncodeDict = @{
                              //first row, qwertyuiop
                              @"q": @[@1.0f, @1.0f],
                              @"w": @[@3.0f, @1.0f],
                              @"e": @[@5.0f, @1.0f],
                              @"r": @[@7.0f, @1.0f],
                              @"t": @[@9.0f, @1.0f],
                              @"y": @[@11.0f, @1.0f],
                              @"u": @[@13.0f, @1.0f],
                              @"i": @[@15.0f, @1.0f],
                              @"o": @[@17.0f, @1.0f],
                              @"p": @[@19.0f, @1.0f],

                              //second row, asdfghjkl
                              @"a": @[@2.0f, @2.0f],
                              @"s": @[@4.0f, @2.0f],
                              @"d": @[@6.0f, @2.0f],
                              @"f": @[@8.0f, @2.0f],
                              @"g": @[@10.0f, @2.0f],
                              @"h": @[@12.0f, @2.0f],
                              @"j": @[@14.0f, @2.0f],
                              @"k": @[@16.0f, @2.0f],
                              @"l": @[@18.0f, @2.0f],

                              //third row, zxcvbnm
                              @"z": @[@4.0f, @3.0f],
                              @"x": @[@6.0f, @3.0f],
                              @"c": @[@8.0f, @3.0f],
                              @"v": @[@10.0f, @3.0f],
                              @"b": @[@12.0f, @3.0f],
                              @"n": @[@14.0f, @3.0f],
                              @"m": @[@16.0f, @3.0f]
                              };



  self.fullKeyboardDecodeDict = [@[] mutableCopy];
  for (NSUInteger m = 0; m < 20; m++) {
    NSMutableArray *temp = [NSMutableArray array];
    for (NSUInteger n = 0; n < 4; n++) {
      [temp addObject:[NSNull null]];
    }
    [self.fullKeyboardDecodeDict addObject:temp];
  }

  self.fullKeyboardDecodeDict[1][1] = @"q";
  self.fullKeyboardDecodeDict[3][1] = @"w";
  self.fullKeyboardDecodeDict[5][1] = @"e";
  self.fullKeyboardDecodeDict[7][1] = @"r";
  self.fullKeyboardDecodeDict[9][1] = @"t";
  self.fullKeyboardDecodeDict[11][1] = @"y";
  self.fullKeyboardDecodeDict[13][1] = @"u";
  self.fullKeyboardDecodeDict[15][1] = @"i";
  self.fullKeyboardDecodeDict[17][1] = @"o";
  self.fullKeyboardDecodeDict[19][1] = @"p";


  self.fullKeyboardDecodeDict[2][2] = @"a";
  self.fullKeyboardDecodeDict[4][2] = @"s";
  self.fullKeyboardDecodeDict[6][2] = @"d";
  self.fullKeyboardDecodeDict[8][2] = @"f";
  self.fullKeyboardDecodeDict[10][2] = @"g";
  self.fullKeyboardDecodeDict[12][2] = @"h";
  self.fullKeyboardDecodeDict[14][2] = @"j";
  self.fullKeyboardDecodeDict[16][2] = @"k";
  self.fullKeyboardDecodeDict[18][2] = @"l";

  self.fullKeyboardDecodeDict[4][3] = @"z";
  self.fullKeyboardDecodeDict[6][3] = @"x";
  self.fullKeyboardDecodeDict[8][3] = @"c";
  self.fullKeyboardDecodeDict[10][3] = @"v";
  self.fullKeyboardDecodeDict[12][3] = @"b";
  self.fullKeyboardDecodeDict[14][3] = @"n";
  self.fullKeyboardDecodeDict[16][3] = @"m";

  //  NSLog(@"~~~~~~~~~~~%@", self.fullKeyboardEncodeDict);
  //  NSLog(@"~~~~~~~~~~~%@", self.fullKeyboardDecodeDict);
}

//FIXME, initFullKeyboardWordsMatrixListWithLocalWordsFile use more memory THAN initFullKeyboardWordsMatrixListWithVectorBin, I DON'T KNOW WHY, maybe memory leak
- (void)initFullKeyboardWordsMatrixListWithLocalWordsFile {
  for(int i = 0; i < self.maxLength; i++) {
    std::shared_ptr<fullKeyboardWordsMatrix> matrix(new fullKeyboardWordsMatrix());
    _fullKeyboardWordsMatrixList.push_back(matrix);
  }

  //////////////
  NSFileHandle *inputFile;
  NSString *path = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"asciiLowercseEnglishWords.txt"];
  inputFile = [NSFileHandle fileHandleForReadingAtPath:path];
  [inputFile enumerateTrimmedLinesUsingBlock:^(NSString *word, BOOL *stop) {
    std::vector<float> wordVector;

    //http://stackoverflow.com/questions/4158646/most-efficient-way-to-iterate-over-all-the-chars-in-an-nsstring
    NSUInteger wordLength = word.length;
    unichar buffer[wordLength + 1];
    [word getCharacters:buffer range:NSMakeRange(0, wordLength)];
    //NSLog(@"getCharacters:range: with unichar buffer");
    for(int i = 0; i < wordLength; i++) {
      NSString *charStr = [NSString stringWithCharacters:&buffer[i] length:1];
      //NSLog(@"Letter %d: %C,   char string is: %@", i, buffer[i], charStr);

      //////////////////////////
      NSArray *numberArray = self.fullKeyboardEncodeDict[charStr];
      NSNumber *number = numberArray[0];
      float floatValue0 = number.floatValue;
      number = numberArray[1];
      float floatValue1 = number.floatValue;
      //NSLog(@"** %f, %f", floatValue0, floatValue1);
      wordVector.push_back(floatValue0);
      wordVector.push_back(floatValue1);
    }

    //std::cout << "------ " << self.fullKeyboardWordsMatrixList.size() << std::endl;
    //std::cout << "------ " << _fullKeyboardWordsMatrixList.size() << std::endl;
    std::shared_ptr<fullKeyboardWordsMatrix> matrix = _fullKeyboardWordsMatrixList[wordLength - 1];
    matrix->push_back(wordVector);
  }];
  [inputFile closeFile];
}


- (void)initFullKeyboardWordsMatrixListWithVectorBin {
  for(int i = 0; i < self.maxLength; i++) {
    NSString *fileName = [NSString stringWithFormat:@"vector%d.bin", i];
    NSString *filePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:filePath];

    // Deserialize the serialized data.
    msgpack::unpacked msg;    // includes memory pool and deserialized object
    msgpack::unpack(msg, (char *)data.bytes, data.length);
    msgpack::object obj = msg.get();

    // Convert the deserialized object to staticaly typed object.
    fullKeyboardWordsMatrix *matrix = new fullKeyboardWordsMatrix();
    obj.convert(&matrix);

    //TODO, graceful handle the error
    obj.as<fullKeyboardWordsMatrix>();  //if type is mismatched, msgpack::type_error is thrown

    //FIXME, is memory management correct??
    std::shared_ptr<fullKeyboardWordsMatrix> matrixShare(matrix);
    _fullKeyboardWordsMatrixList.push_back(matrixShare);
  }
}


- (void)msgpackFullKeyboardWordsMatrixListToFile {
  //http://stackoverflow.com/questions/409348/iteration-over-vector-in-c
  for(std::vector<std::shared_ptr<fullKeyboardWordsMatrix>>::size_type i = 0; i != self.fullKeyboardWordsMatrixList.size(); i++) {
    std::shared_ptr<fullKeyboardWordsMatrix> matrix = self.fullKeyboardWordsMatrixList[i];

    // Serialize it.
    msgpack::sbuffer sbuf;  // simple buffer
    msgpack::pack(&sbuf, *matrix.get());//FIXME, OR ?? msgpack::pack(&sbuf, *matrix);
    //std::cout << "@@@@@@:  " << sbuf.data() << "  and size is: " << sbuf.size() << std::endl;


    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/vector%lu.bin", documentsDirectory, i];

    NSLog(@"%@", fileName);
    NSData *data = [NSData dataWithBytes:sbuf.data() length:sbuf.size()];
    [data writeToFile:fileName atomically:YES];
  }
}

//https://github.com/msgpack/msgpack-cli/wiki/Custom-serialization -- can serialize kdtree directly ??
//- (void)msgpackFullKeyboardKDTreeListToFile {
//  for(std::vector<std::shared_ptr<fullKeyboardKDTree>>::size_type i = 0; i != self.fullKeyboardKDTreeList.size(); i++) {
//    std::shared_ptr<fullKeyboardKDTree> kdTree = self.fullKeyboardKDTreeList[i];
//
//    // Serialize it.
//    msgpack::sbuffer sbuf;  // simple buffer
//    msgpack::pack(&sbuf, *kdTree.get());//FIXME, OR ?? msgpack::pack(&sbuf, *matrix);
//    //std::cout << "@@@@@@:  " << sbuf.data() << "  and size is: " << sbuf.size() << std::endl;
//
//
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *fileName = [NSString stringWithFormat:@"%@/kdTree%lu.bin", documentsDirectory, i];
//
//    NSLog(@"%@", fileName);
//    NSData *data = [NSData dataWithBytes:sbuf.data() length:sbuf.size()];
//    [data writeToFile:fileName atomically:YES];
//  }
//}


- (void)initKDTree {
  //http://stackoverflow.com/questions/409348/iteration-over-vector-in-c
  for(std::vector<std::shared_ptr<fullKeyboardWordsMatrix>>::size_type i = 0; i != self.fullKeyboardWordsMatrixList.size(); i++) {
    //std::cout << "^^initKDTree^^ " << i << "\n";
    std::shared_ptr<fullKeyboardWordsMatrix> matrix = self.fullKeyboardWordsMatrixList[i];
    std::shared_ptr<fullKeyboardKDTree> kdTree(new fullKeyboardKDTree((int)i + 1, *matrix, 10 /* max leaf */));
    kdTree->index->buildIndex();

    _fullKeyboardKDTreeList.push_back(kdTree);
  }
}


- (void)testMsgpack {
  // This is target object.
  std::vector<std::string> target;
  target.push_back("Hello,");
  target.push_back("World!");

  // Serialize it.
  msgpack::sbuffer sbuf;  // simple buffer
  msgpack::pack(&sbuf, target);
  std::cout << "@@@@@@:  " << sbuf.data() << std::endl;

  // Deserialize the serialized data.
  msgpack::unpacked msg;    // includes memory pool and deserialized object
  msgpack::unpack(msg, sbuf.data(), sbuf.size());
  msgpack::object obj = msg.get();

  // Print the deserialized object to stdout.
  std::cout << obj << std::endl;    // ["Hello," "World!"]

  // Convert the deserialized object to staticaly typed object.
  std::vector<std::string> result;
  obj.convert(&result);

  // If the type is mismatched, it throws msgpack::type_error.
  //  obj.as<int>();  // type is mismatched, msgpack::type_error is thrown
  obj.as<std::vector<std::string> >();  // type is mismatched, msgpack::type_error is thrown
}

- (instancetype)init {
  self = [super init];
  if (self) {
    [self testMsgpack];

    self.maxLength = 24;//the max length or all words -- get this number in python code
    [self initEncodeAndDecodeDict];


    CGFloat time;
    BOOL initMatrixListWithBinFile = YES;

    if (initMatrixListWithBinFile) {
      time = BNRTimeBlock(^{
        [self initFullKeyboardWordsMatrixListWithVectorBin];
      });
      printf ("<1> initFullKeyboardWordsMatrixListWithVectorBin, use time: %f\n", time);
    } else {
      time = BNRTimeBlock(^{
        [self initFullKeyboardWordsMatrixListWithLocalWordsFile];
      });
      printf ("<1.1> initFullKeyboardWordsMatrixListWithLocalWordsFile, use time: %f\n", time);

      time = BNRTimeBlock(^{
        [self msgpackFullKeyboardWordsMatrixListToFile];
      });
      printf ("<1.2> msgpackFullKeyboardWordsMatrixListToFile, use time: %f\n", time);
    }


    time = BNRTimeBlock(^{
      [self initKDTree];
    });
    printf ("<2> initKDTree, use time: %f\n", time);


    NSLog(@"%s", __FUNCTION__);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      CGFloat time2;
      time2 = BNRTimeBlock(^{
        [self searchWithString:@"application"];
      });
      printf ("do a seasrch use time: %f\n", time2);
    });
  }
  return self;
}


- (NSArray *)searchWithString:(NSString *)string {
  NSMutableArray *result = [@[] mutableCopy];
  NSString *inputWord = [string copy];
  inputWord = inputWord.lowercaseString;

  if ([inputWord length] == 0) {
    return [NSArray arrayWithArray:result];
  }
  if ([inputWord length] > self.maxLength) {
    return [NSArray arrayWithArray:result];
  }

//  NSCharacterSet *nonLettersSet = [[NSCharacterSet letterCharacterSet] invertedSet];
//  if (![[inputWord stringByTrimmingCharactersInSet:nonLettersSet] isEqualToString:inputWord]) {
//    return [NSArray arrayWithArray:result];
//  }

  NSCharacterSet *lettersSet = [NSCharacterSet letterCharacterSet];
  if (![[inputWord stringByTrimmingCharactersInSet:lettersSet] isEqualToString:@""]) {
    return [NSArray arrayWithArray:result];
  }

  std::vector<float> inputWordVector;

  NSUInteger wordLength = inputWord.length;
  unichar buffer[wordLength + 1];
  [inputWord getCharacters:buffer range:NSMakeRange(0, wordLength)];
  //NSLog(@"getCharacters:range: with unichar buffer");
  for(int i = 0; i < wordLength; i++) {
    NSString *charStr = [NSString stringWithCharacters:&buffer[i] length:1];
    //NSLog(@"Letter %d: %C,   char string is: %@", i, buffer[i], charStr);

    //////////////////////////
    NSArray *numberArray = self.fullKeyboardEncodeDict[charStr];
    NSNumber *number = numberArray[0];
    float floatValue0 = number.floatValue;
    number = numberArray[1];
    float floatValue1 = number.floatValue;
    //NSLog(@"** %f, %f", floatValue0, floatValue1);
    inputWordVector.push_back(floatValue0);
    inputWordVector.push_back(floatValue1);
  }


  //DO a knn search
  std::shared_ptr<fullKeyboardKDTree> kdTree = self.fullKeyboardKDTreeList[wordLength - 1];
  std::shared_ptr<fullKeyboardWordsMatrix> matrix = self.fullKeyboardWordsMatrixList[wordLength - 1];

  const size_t num_results = 20;
  std::vector<size_t> ret_indexes(num_results);
  std::vector<float> out_dists_sqr(num_results);

  nanoflann::KNNResultSet<float> resultSet(num_results);
  resultSet.init(&ret_indexes[0], &out_dists_sqr[0] );
  kdTree->index->findNeighbors(resultSet, &inputWordVector[0], nanoflann::SearchParams(10));

  std::cout << "knnSearch(nn="<<num_results<<"): \n";
  for (size_t i=0;i<num_results;i++) {
    std::cout << "ret_index["<<i<<"]=" << ret_indexes[i] << " out_dist_sqr=" << out_dists_sqr[i] << std::endl;

    std::vector<float> v = matrix->at(ret_indexes[i]);
    NSMutableString *s = [@"" mutableCopy];
    for (std::vector<float>::size_type i = 0; i != v.size(); i = i + 2) {
      NSString *c = self.fullKeyboardDecodeDict[(int)v[i]][(int)v[i + 1]];
      //NSLog(@"#######  %@", c);
      [s appendString:c];
    }
//    NSLog(@"&&&&&&&&&&& %@", s);

    [result addObject:s];
  }

  return [NSArray arrayWithArray:result];
}

@end
