import pytest
import sys
import os

# Add the parent directory to the sys.path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import mb_app  # Correct import to match your module name

def test_main(capfd):
    # Run the main function
    mb_app.main()  # Use the correct module name here

    # Capture the output
    out, err = capfd.readouterr()

    # Define the expected output
    expected_output = (
        "Starting the application...\n"
        "Running the application...\n"
        "Computation result: 42\n"
        "Ending the application.\n"
    )

    # Assert that the output matches the expected output
    assert out == expected_output
    assert err == ""

if __name__ == "__main__":
    pytest.main()
