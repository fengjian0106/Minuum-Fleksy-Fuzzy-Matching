# Minuum-Fleksy-Fuzzy-Matching
This is a technology demonstration for how to implement a fuzzy words matching system like Minuum or Fleksy (input methods).

## What is this?
The Minuum and Fleksy input methods are so cool, and I am interested in how they can do a crazy fuzzy words matching. After a lot of research, I can not find the details of their implementations. The most valuable clue is [http://minuum.com/model-your-users-algorithms-behind-the-minuum-keyboard/](http://minuum.com/model-your-users-algorithms-behind-the-minuum-keyboard/); the `language model` is not very hard for me, but the `spatial model` is a new concept for me. After a long time of learning process, I found the magic for `spatial model` --  [k-nearest neighbors algorithm](http://en.wikipedia.org/wiki/K-nearest_neighbors_algorithm) of `Machine Learning`. And I wrote the concept prototype code using a `spatial model`.

## How to run it?
For the Python version, you should install the `numpy` and `sklearn` libraries:

```bash
python -m pip install numpy sklearn
```

For the iOS version, just compile and run it.
