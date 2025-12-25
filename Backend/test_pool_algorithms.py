import pool_algorithms
import random

def test_random():
    print("Testing select_random...")
    pool = [f"q{i}" for i in range(10)]
    
    # Test normal selection
    selected = pool_algorithms.select_random(5, pool)
    assert len(selected) == 5
    for s in selected:
        assert s in pool
        
    # Test selecting more than pool size
    selected = pool_algorithms.select_random(15, pool)
    assert len(selected) == 10
    
    # Test empty pool
    assert pool_algorithms.select_random(5, []) == []
    print("select_random passed!")

def test_random_not_repeated():
    print("Testing select_random_not_repeated...")
    pool = [f"q{i}" for i in range(10)]
    answered = ["q0", "q1", "q2"]
    
    # Test prioritizing unanswered
    selected = pool_algorithms.select_random_not_repeated(5, pool, answered)
    assert len(selected) == 5
    not_answered_count = sum(1 for q in selected if q not in answered)
    # Since there are 7 unanswered, we should be able to get 5
    assert not_answered_count == 5
    
    # Test needing to use answered
    selected = pool_algorithms.select_random_not_repeated(9, pool, answered)
    assert len(selected) == 9
    not_answered_count = sum(1 for q in selected if q not in answered)
    assert not_answered_count == 7 # All unanswered selected
    answered_count = sum(1 for q in selected if q in answered)
    assert answered_count == 2 # 2 from answered
    
    # Test empty pool
    assert pool_algorithms.select_random_not_repeated(5, [], answered) == []
    print("select_random_not_repeated passed!")

def test_error_review():
    print("Testing select_error_review...")
    # (id, correct, wrong)
    stats = [
        ("q0", 5, 1),   # ratio ~0.2
        ("q1", 1, 5),   # ratio ~5
        ("q2", 5, 5),   # ratio ~1
    ]
    
    # Probabilistic check: q1 > q2 > q0
    # Over 5000 selections, counts should reflect this
    counts = {"q0": 0, "q1": 0, "q2": 0}
    for _ in range(5000):
        selected = pool_algorithms.select_error_review(1, stats)
        counts[selected[0]] += 1
        
    print(f"Selection counts over 5000 trials: {counts}")
    assert counts["q1"] > counts["q2"]
    assert counts["q2"] > counts["q0"]
    
    # Test requesting multiple
    selected = pool_algorithms.select_error_review(2, stats)
    assert len(selected) == 2
    
    # Test zero errors case (uniform)
    stats_zero = [("q0", 10, 0), ("q1", 5, 0)]
    selected = pool_algorithms.select_error_review(1, stats_zero)
    assert len(selected) == 1
    
    # Test epsilon behavior (no division by zero)
    stats_zero_both = [("q0", 0, 0), ("q1", 0, 0)]
    selected = pool_algorithms.select_error_review(1, stats_zero_both)
    assert len(selected) == 1

    print("select_error_review passed!")

if __name__ == "__main__":
    try:
        test_random()
        test_random_not_repeated()
        test_error_review()
        print("\nAll pool algorithm tests passed!")
    except Exception as e:
        print(f"\nTests failed: {e}")
        exit(1)
