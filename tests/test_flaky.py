import os

import pytest

# Path to the counter file — tracks how many times this test has run.
# This file is in .gitignore so it never gets committed.
# Delete it to reset the flaky behavior.
COUNTER_FILE = "flaky_counter.txt"


def test_database_connection_warmup():
    """
    Simulates a flaky test caused by a database connection warmup issue.

    Behavior:
      - FIRST run  → FAILS  (simulates cold connection pool not ready)
      - SECOND run → PASSES (simulates warmed-up connection pool)

    This is intentionally flaky to demonstrate the self-healing pipeline's
    ability to detect a flaky test failure and automatically retry the job.

    To reset the flaky behavior: delete flaky_counter.txt
    """
    if not os.path.exists(COUNTER_FILE):
        # First run — create the counter file and fail
        with open(COUNTER_FILE, "w") as f:
            f.write("1")
        pytest.fail(
            "Database connection pool not warmed up yet. "
            "This is a known flaky test — retry will pass."
        )
    else:
        # Subsequent runs — connection is "warmed up", test passes
        with open(COUNTER_FILE, "r") as f:
            count = int(f.read().strip())

        with open(COUNTER_FILE, "w") as f:
            f.write(str(count + 1))

        # Simulate a successful DB ping
        db_response = {"connected": True, "latency_ms": 12}
        assert db_response["connected"] is True
        assert db_response["latency_ms"] < 100
