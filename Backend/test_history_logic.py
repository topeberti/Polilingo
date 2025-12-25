from collections import defaultdict
from typing import List, Dict

# Core logic from history.py
def aggregate_history_data(data: List[Dict]) -> List[Dict]:
    if not data:
        return []
        
    stats_map = defaultdict(lambda: {"total": 0, "correct": 0})
    for record in data:
        q_id = record.get("question_id")
        if not q_id:
            continue
            
        stats_map[q_id]["total"] += 1
        if record.get("correct") is True:
            stats_map[q_id]["correct"] += 1
            
    return [
        {
            "question_id": q_id,
            "total_attempts": stats["total"],
            "correct_answers": stats["correct"]
        }
        for q_id, stats in stats_map.items()
    ]

# Test data
MOCK_HISTORY_DATA = [
    {"question_id": "q1", "correct": True},
    {"question_id": "q1", "correct": False},
    {"question_id": "q2", "correct": True},
    {"question_id": "q1", "correct": True},
    {"question_id": "q3", "correct": False},
]

def test_logic():
    results = aggregate_history_data(MOCK_HISTORY_DATA)
    q_stats = {item["question_id"]: item for item in results}
    
    assert len(results) == 3
    assert q_stats["q1"]["total_attempts"] == 3
    assert q_stats["q1"]["correct_answers"] == 2
    assert q_stats["q2"]["total_attempts"] == 1
    assert q_stats["q2"]["correct_answers"] == 1
    assert q_stats["q3"]["total_attempts"] == 1
    assert q_stats["q3"]["correct_answers"] == 0
    print("Logic test passed!")

if __name__ == "__main__":
    test_logic()
