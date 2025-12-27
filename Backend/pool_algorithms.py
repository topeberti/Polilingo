import random
from typing import List, Tuple, Dict

def select_random(n: int, pool: List[str]) -> List[str]:
    """
    Randomly select n questions from the pool.
    
    Tag: random
    """
    if not pool:
        return []
    
    # Cap n to pool size as per condition
    n = min(n, len(pool))
    return random.sample(pool, n)

def select_random_not_repeated(n: int, pool: List[str], answered: List[str]) -> List[str]:
    """
    Select n questions from the pool randomly, prioritizing questions not already answered.
    
    Tag: random_not_repeated
    """
    if not pool:
        return []
    
    n = min(n, len(pool))
    
    answered_set = set(answered)
    not_answered = [q for q in pool if q not in answered_set]
    
    selected = []
    
    # 1. Select as many as possible from not answered
    num_from_not_answered = min(n, len(not_answered))
    if num_from_not_answered > 0:
        selected.extend(random.sample(not_answered, num_from_not_answered))
    
    # 2. If still need more, select from answered
    remaining_needed = n - len(selected)
    if remaining_needed > 0:
        answered_in_pool = [q for q in pool if q in answered_set]
        if answered_in_pool:
            selected.extend(random.sample(answered_in_pool, min(remaining_needed, len(answered_in_pool))))
            
    return selected

def select_error_review(n: int, question_stats: List[Tuple[str, int, int]]) -> List[str]:
    """
    Select n questions from the pool weighted by the ratio of wrong to correct answers,
    without repetition.
    
    Ratio = N_wrong / (N_correct + epsilon)
    
    Tag: error_review
    """
    if not question_stats:
        return []
    
    n = min(n, len(question_stats))
    epsilon = 1e-6
    
    # Calculate weights and keys for Efraimidis-Spirakis weighted sampling without replacement
    keys = []
    for q_id, n_correct, n_wrong in question_stats:
        ratio = n_wrong / (n_correct + epsilon)
        # We use a small random value if ratio is exactly 0 to allow some selection probability
        # but keep it proportional if possible.
        weight = max(ratio, epsilon)
        # Efraimidis-Spirakis algorithm: key = u^(1/w)
        key = random.random() ** (1.0 / weight)
        keys.append((key, q_id))
        
    # Sort by key descending and pick top n
    keys.sort(key=lambda x: x[0], reverse=True)
    selected = [q_id for _, q_id in keys[:n]]
        
    return selected
