# -*- coding: utf-8 -*-
import string
import time
from collections import OrderedDict
import numpy as np
from sklearn.neighbors import KDTree, BallTree

###########################
###########################
#http://stackoverflow.com/questions/3277503/python-read-file-line-by-line-into-array
#filepath = '/usr/share/dict/words'
filepath = './words'
lines = [line.rstrip('\n').lower() for line in open(filepath)]
print('<1> ##total %r words' % len(lines))

#remove duplicate word
#http://stackoverflow.com/questions/480214/how-do-you-remove-duplicates-from-a-list-in-python-whilst-preserving-order
lines = list(OrderedDict.fromkeys(lines))
print('<2> ##after remove duplicates,  total %r words' % len(lines))

#remove non ascii lowercase letter
def containOnlyAsciiLowercaseLetters(s):
    for c in s:
        if not c in string.ascii_lowercase:
            return False
    return True

lines = filter(containOnlyAsciiLowercaseLetters, lines)
print('<3> ##after remove non ascii lowercase letters,  total %r words' % len(lines))

maxLength = max(map(lambda word: len(word), lines))
print('<4> longest word has %r characters' % maxLength)



###########################
###########################
fullKeyboardEncodeDict = {}
fullKeyboardDecodeDict = []
for x in range(20):
    temp = []
    for y in range(4):
        temp.append(None)
    fullKeyboardDecodeDict.append(temp)


#####first row, qwertyuiop
fullKeyboardEncodeDict['q'] = [1, 1]
fullKeyboardEncodeDict['w'] = [3, 1]
fullKeyboardEncodeDict['e'] = [5, 1]
fullKeyboardEncodeDict['r'] = [7, 1]
fullKeyboardEncodeDict['t'] = [9, 1]
fullKeyboardEncodeDict['y'] = [11, 1]
fullKeyboardEncodeDict['u'] = [13, 1]
fullKeyboardEncodeDict['i'] = [15, 1]
fullKeyboardEncodeDict['o'] = [17, 1]
fullKeyboardEncodeDict['p'] = [19, 1]

fullKeyboardDecodeDict[1][1] = 'q'
fullKeyboardDecodeDict[3][1] = 'w'
fullKeyboardDecodeDict[5][1] = 'e'
fullKeyboardDecodeDict[7][1] = 'r'
fullKeyboardDecodeDict[9][1] = 't'
fullKeyboardDecodeDict[11][1] = 'y'
fullKeyboardDecodeDict[13][1] = 'u'
fullKeyboardDecodeDict[15][1] = 'i'
fullKeyboardDecodeDict[17][1] = 'o'
fullKeyboardDecodeDict[19][1] = 'p'

#####second row, asdfghjkl
fullKeyboardEncodeDict['a'] = [2, 2]
fullKeyboardEncodeDict['s'] = [4, 2]
fullKeyboardEncodeDict['d'] = [6, 2]
fullKeyboardEncodeDict['f'] = [8, 2]
fullKeyboardEncodeDict['g'] = [10, 2]
fullKeyboardEncodeDict['h'] = [12, 2]
fullKeyboardEncodeDict['j'] = [14, 2]
fullKeyboardEncodeDict['k'] = [16, 2]
fullKeyboardEncodeDict['l'] = [18, 2]

fullKeyboardDecodeDict[2][2] = 'a'
fullKeyboardDecodeDict[4][2] = 's'
fullKeyboardDecodeDict[6][2] = 'd'
fullKeyboardDecodeDict[8][2] = 'f'
fullKeyboardDecodeDict[10][2] = 'g'
fullKeyboardDecodeDict[12][2] = 'h'
fullKeyboardDecodeDict[14][2] = 'j'
fullKeyboardDecodeDict[16][2] = 'k'
fullKeyboardDecodeDict[18][2] = 'l'

#####third row, zxcvbnm
fullKeyboardEncodeDict['z'] = [4, 3]
fullKeyboardEncodeDict['x'] = [6, 3]
fullKeyboardEncodeDict['c'] = [8, 3]
fullKeyboardEncodeDict['v'] = [10, 3]
fullKeyboardEncodeDict['b'] = [12, 3]
fullKeyboardEncodeDict['n'] = [14, 3]
fullKeyboardEncodeDict['m'] = [16, 3]

fullKeyboardDecodeDict[4][3] = 'z'
fullKeyboardDecodeDict[6][3] = 'x'
fullKeyboardDecodeDict[8][3] = 'c'
fullKeyboardDecodeDict[10][3] = 'v'
fullKeyboardDecodeDict[12][3] = 'b'
fullKeyboardDecodeDict[14][3] = 'n'
fullKeyboardDecodeDict[16][3] = 'm'


print('<5.1> fullKeyboardEncodeDict is  %r' % fullKeyboardEncodeDict)
print('<5.2> fullKeyboardDecodeDict is  %r' % fullKeyboardDecodeDict)


###########################
###########################
fullKeyboardWordsMatrixList = []
fullKeyboardKDTreeList = []
fullKeyboardBallTreeList = []
for i in range(0, maxLength):
    fullKeyboardWordsMatrixList.append([])
    fullKeyboardKDTreeList.append(None)
    fullKeyboardBallTreeList.append(None)
#print('<6> init fullKeyboardWordsMatrixList, with %r []' % len(fullKeyboardWordsMatrixList))

for word in lines:
    wordVector = []
    for char in word:
        wordVector.extend(fullKeyboardEncodeDict[char])
    fullKeyboardWordsMatrixList[len(word) - 1].append(wordVector)


#print(fullKeyboardWordsMatrixList[0:2])


###########################
###########################
print('/////////////////////////')
print('/////////////////////////')
for index, matrix in enumerate(fullKeyboardWordsMatrixList):
    start = time.time()
    fullKeyboardKDTreeList[index] = KDTree(np.array(matrix), leaf_size=30, metric='euclidean')
    elapsed = time.time() - start
    print('[word with %r characters]: %r, &&create KDTree use %r seconds' % (index + 1, len(matrix),  elapsed))

print('/////////////////////////')
print('/////////////////////////')
for index, matrix in enumerate(fullKeyboardWordsMatrixList):
    start = time.time()
    #fullKeyboardBallTreeList[index] = BallTree(np.array(matrix), leaf_size=30, metric='euclidean')
    fullKeyboardBallTreeList[index] = BallTree(np.array(matrix), leaf_size=30)
    elapsed = time.time() - start
    print('[word with %r characters]: %r, &&create BallTree use %r seconds' % (index + 1, len(matrix),  elapsed))

print('/////////////////////////')
print('/////////////////////////')


###########################
###########################
while True:
    inputWord = raw_input("Please enter a word:")
    if inputWord.strip() == '.exit':
        break

    if inputWord == '':
        continue

    inputWord = inputWord.lower()
    if containOnlyAsciiLowercaseLetters(inputWord) == False:
        print('!!Your input word should not contain non ascii letters, Please input again')
        continue

    if len(inputWord) > maxLength:
        print('!!Your input word is longer than the longest word in the test word list, Please input again')
        continue

    #inputWordLength = len(inputWord)
    inputWordVector = []
    for char in inputWord:
        inputWordVector.extend(fullKeyboardEncodeDict[char])

    inputWordVectorLength = len(inputWordVector)

###########################
###########################
    print('Your input word is: %r, and vector is: %r\n' % (inputWord, inputWordVector))

    def fullKeyboardDecodeNums(nums):
        s = ''
        for i in range(0, len(nums), 2):
            c = fullKeyboardDecodeDict[nums[i]][nums[i + 1]]
            s += c
        return s

    searchMatrix = fullKeyboardWordsMatrixList[len(inputWord) - 1]


    resultK = 25
###########################
###########################
    #search with Matrix
    resultVectorAndDistanceList = []
    start = time.time()
    for wordsVector in searchMatrix:
        #print('    wordsVector is %r' %  wordsVector)
        distance = 0
        for i in range(inputWordVectorLength):
            temp = inputWordVector[i] - wordsVector[i]
            distance = distance + temp * temp
        if distance < (10 * (inputWordVectorLength + 1)):
            resultVectorAndDistanceList.append((wordsVector, distance))

    #print(resultvectoranddistancelist)
    resultVectorAndDistanceList = sorted(resultVectorAndDistanceList, key = lambda result: result[1])
    wordsDecoded = map(fullKeyboardDecodeNums, map(lambda x: x[0], resultVectorAndDistanceList))

    elapsed = time.time() - start
    print('@@@@@@@@@@@@@@@@@')
    print('@@@@@@@@@@@@@@@@@')
    print('Your input word is: %r' % (inputWord))
    print('--liner iterate wordsMatrix with %r wordsVector,  search use %r seconds' % (len(searchMatrix), elapsed))
    #print('words is %r\n' % wordsDecoded)
    length = len(resultVectorAndDistanceList)
    for i in range(length if length < 21 else resultK):
        item = resultVectorAndDistanceList[i]
        print('  %r,  %r' % (fullKeyboardDecodeNums(item[0]), item[1]))

###########################
###########################
    #search with KDTree
    searchKDTree = fullKeyboardKDTreeList[len(inputWord) - 1]

    start = time.time()
    result = searchKDTree.query(np.array([inputWordVector]), k=resultK, return_distance=True)
    resultIndexs = result[1].tolist()[0]
    end = time.time()
    elapsed = end - start

    #########
    #print('search use %r seconds' % (elapsed))
    #print('@@@@@@@@@@@@@@@@@')
    #print('result[0] : %r' % type(result[0]))
    #print('result[1] : %r' % type(result[1]))
    #print('result[0] : %r' % result[0])
    #print('result[1] : %r' % result[1])
    #print('result[1].tolist : %r' % resultIndexs)

    #for i in resultIndexs:
    #    print(searchMatrix[i])


    wordsDecoded = map(fullKeyboardDecodeNums, map(lambda i: searchMatrix[i], resultIndexs))
    print('@@@@@@@@@@@@@@@@@')
    print('@@@@@@@@@@@@@@@@@')
    print('Your input word is: %r' % (inputWord))
    print('--KDTree search use %r seconds' % (elapsed))
    #print('words is %r\n' % wordsDecoded)
    distanceList = result[0].tolist()[0]
    for i, word in enumerate(wordsDecoded):
        print('  %r,  %r' % (word, distanceList[i]))
    #print('result : %r' % np.array(searchMatrix)[result[1]])


###########################
###########################
    #search with BallTree
    searchBallTree = fullKeyboardBallTreeList[len(inputWord) - 1]

    start = time.time()
    result = searchBallTree.query(np.array([inputWordVector]), k=resultK, return_distance=True)
    resultIndexs = result[1].tolist()[0]
    end = time.time()
    elapsed = end - start


    wordsDecoded = map(fullKeyboardDecodeNums, map(lambda i: searchMatrix[i], resultIndexs))
    print('@@@@@@@@@@@@@@@@@')
    print('@@@@@@@@@@@@@@@@@')
    print('Your input word is: %r' % (inputWord))
    print('--BallTree search use %r seconds' % (elapsed))
    #print('words is %r\n' % wordsDecoded)
    distanceList = result[0].tolist()[0]
    for i, word in enumerate(wordsDecoded):
        print('  %r,  %r' % (word, distanceList[i]))

    print('=============================')
    print('=============================\n\n\n')

