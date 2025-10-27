![Robot Framework](https://img.shields.io/badge/Robot%20Framework-7.3.2-brightgreen)

# Robot Framework Selenium-based Project for Demoblaze

This project automates end-to-end user journeys and API/UI validations for [Demoblaze](https://www.demoblaze.com/) using Robot Framework, SeleniumLibrary, and RequestsLibrary.

## Features

- End-to-end UI automation (signup, login, add to cart, place order, logout)
- API and UI product validation
- Ready for CI/CD with GitHub Actions

## Prerequisites

- Python 3.8+
- Google Chrome (for local runs)
- [pip](https://pip.pypa.io/en/stable/)

## Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/khinsushein/RobotFramwork_Seleniumbased_Project.git
   cd RobotFramwork_Seleniumbased_Project
   ```

2. **Install dependencies:**
   ```sh
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   pip install -r requirements.txt
   ```

## Running Tests Locally

```sh
robot tests/
```

## Continuous Integration (GitHub Actions)

- Chrome is installed automatically in CI.
- ChromeDriver is managed by [`webdriver_manager`](https://github.com/SergeyPirogov/webdriver_manager).
- Test results (`output.xml`, `log.html`, `report.html`) are uploaded as workflow artifacts.

## Project Structure

```
.
├── tests/
│   ├── demoblaze_e2e.robot
│   ├── demoblaze_api_UI_01.robot
│   └── demoblaze_api_UI_02.robot
|   └── demoblaze_api.robot
    


├── requirements.txt
└── .github/
    └── workflows/
        └── robotframework.yml
```

## HTML report
robot  [Download latest HTML report](https://github.com/khinsushein/RobotFramwork_Seleniumbased_Project/actions)
-  Chrome is installed automatically in CI.
- ChromeDriver is managed by [`webdriver_manager`](https://github.com/SergeyPirogov/webdriver_manager).
- Test results (`output.xml`, `log.html`, `report.html`) are uploaded as workflow artifacts.


## Troubleshooting

- **SessionNotCreatedException:** Ensure Chrome is installed and `webdriver_manager` is used for driver management.
- **No keyword with name 'Create Session':** Make sure `robotframework-requests` is in `requirements.txt`.

## Latest Test Results

**Pass:** 5  
**Fail:** 0  

See [log.html](https://github.com/khinsushein/RobotFramwork_Seleniumbased_Project/actions) for details.

## Author
[Khin Su Shein] — QA Automation Engineer  
Based in France, open to Luxembourg/Switzerland roles





---

