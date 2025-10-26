*** Settings ***
Library    SeleniumLibrary
Library    String

*** Variables ***
${URL}     https://www.demoblaze.com/
${BROWSER}    chrome
${TIMEOUT}    10

*** Keywords ***
Open Chrome With CI Options
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --no-sandbox
    Call Method    ${options}    add_argument    --disable-dev-shm-usage
    Call Method    ${options}    add_argument    --headless
    Call Method    ${options}    add_argument    --disable-gpu
    Create WebDriver    Chrome      options=${options}
    Go To    https://www.demoblaze.com/
Generate Unique Credentials
    ${rand}=        Generate Random String    8    [LOWER]
    ${username}=    Set Variable    testuser_${rand}
    ${password}=    Set Variable    testpass_${rand}
    [RETURN]    ${username}    ${password}

Sign Up
    [Arguments]    ${username}    ${password}
    Wait Until Element Is Visible    xpath=//a[normalize-space(.)='Sign up']    ${TIMEOUT}
    Click Element                    xpath=//a[normalize-space(.)='Sign up']
    Wait Until Element Is Visible    id=signInModal    ${TIMEOUT}
    Wait Until Element Is Visible    id=sign-username  ${TIMEOUT}
    Wait Until Element Is Visible    id=sign-password  ${TIMEOUT}
    Clear Element Text               id=sign-username
    Input Text                       id=sign-username    ${username}
    Clear Element Text               id=sign-password
    Input Text                       id=sign-password    ${password}
    # Scope the button to the modal to avoid hidden/duplicate buttons
    Click Button     xpath=//div[@id='signInModal']//button[normalize-space(.)='Sign up']

    # REQUIRED: Demoblaze shows a JS alert with the result
    ${msg}=    Handle Alert    action=ACCEPT    timeout=${TIMEOUT}
    Log    Sign-up alert: ${msg}

    # Close the modal if it stayed open
    Wait Until Keyword Succeeds    3x    1s    Run Keywords
    ...    Run Keyword And Ignore Error    Wait Until Element Is Not Visible    id=signInModal    ${TIMEOUT}
    ...    AND    Run Keyword And Ignore Error    Click Element    css=#signInModal .close

    Should Be Equal As Strings    ${msg}    Sign up successful.

Login
    [Arguments]    ${username}    ${password}
    Wait Until Element Is Visible    xpath=//a[normalize-space(.)='Log in']    ${TIMEOUT}
    Click Element                    xpath=//a[normalize-space(.)='Log in']
    Wait Until Element Is Visible    id=logInModal      ${TIMEOUT}
    Input Text                       id=loginusername    ${username}
    Input Text                       id=loginpassword    ${password}
    Click Button                     xpath=//div[@id='logInModal']//button[normalize-space(.)='Log in']
    # After clicking login, content reloads; give it a moment
    Wait Until Element Is Not Visible    id=logInModal    ${TIMEOUT}
    Wait Until Element Is Visible        id=nameofuser    ${TIMEOUT}
    ${user}=    Get Text    id=nameofuser
    Should Contain    ${user}    ${username}

Add Product To Cart
    [Arguments]    ${product}
    # Ensure we are on home
    Click Element    xpath=//a[@class='navbar-brand' and normalize-space(.)='PRODUCT STORE']
    # Open category, then wait for the product link to appear
    Click Element    xpath=//a[normalize-space(.)='Laptops']
    Wait Until Element Is Visible    xpath=//a[normalize-space(.)='${product}']    ${TIMEOUT}
    Sleep    1s
    Click Element    xpath=//a[normalize-space(.)='${product}']
    Wait Until Element Is Visible    xpath=//a[normalize-space(.)='Add to cart']    ${TIMEOUT}
    Click Element    xpath=//a[normalize-space(.)='Add to cart']

    # REQUIRED: accept "Product added" alert
    ${cart_msg}=    Handle Alert    action=ACCEPT    timeout=${TIMEOUT}
    Log    Add-to-cart alert: ${cart_msg}

Place Order
    Click Element    xpath=//a[normalize-space(.)='Cart']
    Wait Until Page Contains Element    xpath=//button[normalize-space(.)='Place Order']    ${TIMEOUT}
    Click Element    xpath=//button[normalize-space(.)='Place Order']
    Wait Until Element Is Visible    id=name    ${TIMEOUT}
    Input Text    id=name     Ada Lovelace
    Input Text    id=country  UK
    Input Text    id=city     London
    Input Text    id=card     4111111111111111
    Input Text    id=month    12
    Input Text    id=year     2030
    Click Element    xpath=//button[normalize-space(.)='Purchase']
    # Handle possible alert for missing fields
    ${alert_present}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=3
    Run Keyword If    ${alert_present}    Fail    Order failed due to missing required fields.
    Wait Until Element Is Visible    css=.sweet-alert p    ${TIMEOUT}
    ${amount}=    Get Text    css=.sweet-alert p
    Should Contain    ${amount}    Amount
    Click Element    xpath=//button[normalize-space(.)='OK']

Logout
    # Ensure any open modals are closed before logout
    Run Keyword And Ignore Error    Click Element    css=.modal.show .close
    Wait Until Element Is Not Visible    css=.modal.show    ${TIMEOUT}
    Wait Until Element Is Visible    xpath=//a[normalize-space(.)='Log out']    ${TIMEOUT}
    Wait Until Element Is Enabled    xpath=//a[normalize-space(.)='Log out']    ${TIMEOUT}
    Sleep    1s
    Click Element    xpath=//a[normalize-space(.)='Log out']
    Wait Until Element Is Visible    xpath=//a[normalize-space(.)='Log in']    ${TIMEOUT}

*** Test Cases ***
End-to-End User Journey
    Open Chrome With CI Options
    Maximize Browser Window
    Set Selenium Timeout    ${TIMEOUT}

    ${u}    ${p}=    Generate Unique Credentials
    Log To Console    Using credentials: ${u} / ${p}

    Sign Up    ${u}    ${p}
    Login      ${u}    ${p}
    Add Product To Cart    Sony vaio i5
    Place Order
    Logout
    Close Browser
