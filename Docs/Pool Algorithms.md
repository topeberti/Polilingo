# Pool Algorithms

This document will explain the algorithms used to select questions from the pool for sesions and challenges.

Each algorithm will be explained in detail with the conditions that must be met to use it.

Each algorithm will be implemented in a different function.

Each algorithm will have a unique tag.

## Random Selection Algorithm

This algorithm will select questions from the pool randomly.

Tag: random

**Parameters**

- Number of questions to select
- List of question ids, which is efectively the pool of questions.

**Conditions**

- The number of questions to select must be less than or equal to the number of questions in the pool.
- The list of question ids must not be empty.

**Workflow**

1. Randomly select the desired number of questions from the pool.

**Output**

- List of selected question ids

## Random Not Repeated Algorithm

This algorithm will select questions from the pool randomly without selecting questions that the user has already answered when possible. If the number of questions to select is greater than the number of questions that the user has not answered, the algorithm will select the remaining questions from the pool.

Tag: random_not_repeated

**Parameters**

- Number of questions to select
- List of question ids, which is efectively the pool of questions.
- List of question ids that the user has already answered.

**Conditions**

- The number of questions to select must be less than or equal to the number of questions in the pool.
- The list of question ids must not be empty.

**Workflow**

1. Create a list that contains all the questions that the user has not answered.
2. Randomly select the desired number of questions from the list.
3. If the number of questions to select is greater than the number of questions that the user has not answered, randomly select the remaining questions from the list of answered questions.

**Output**

- List of selected question ids

## Error review algorithm

This algorithm will select questions from the pool weighted by the ratio of wrong to correct answers.

Tag: error_review

**Parameters**

- Number of questions to select
- List tuples of question ids, the number of correct answers and the number of wrong answers.

**Conditions**

- The number of questions to select must be less than or equal to the number of questions in the pool.
- The list of tuples must not be empty.

**Workflow**

1. Compute the ratio with this formula $N_{wrong} / (N_{correct} + \epsilon)$. Where $\epsilon$ is a very small positive number to avoid division by zero.
2. Normalize the ratios so that the sum of all ratios is equal to 1.
3. Randomly select the desired number of questions from the list of tuples weighted by the ratio.

**Output**

- List of selected question ids
