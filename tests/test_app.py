import pytest
import app

def test_main(capfd):
    # Run the main function
    app.main()

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
