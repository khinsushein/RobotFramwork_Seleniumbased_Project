*** Settings ***
Library    RequestsLibrary
Library    String
Library    Collections
Library    SeleniumLibrary

*** Variables ***
${API_BASE}     https://api.demoblaze.com
${TIMEOUT}      15

*** Keywords ***
Open Chrome With CI Options
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --no-sandbox
    Call Method    ${options}    add_argument    --disable-dev-shm-usage
    Call Method    ${options}    add_argument    --headless
    Call Method    ${options}    add_argument    --disable-gpu
    Open Browser    https://api.demoblaze.com    Chrome    options=${options}
    Go To    https://api.demoblaze.com
Make API Session
    &{headers}=    Create Dictionary    Content-Type=application/json
    Create Session    demoblaze    ${API_BASE}    headers=${headers}    timeout=${TIMEOUT}

Signup User
    [Arguments]    ${username}    ${password}
    ${payload}=    Create Dictionary    username=${username}    password=${password}
    ${resp}=    POST On Session    demoblaze    /signup
    ...         json=${payload}
    ...         expected_status=200
    [Return]    ${resp}

Login User
    [Arguments]    ${username}    ${password}
    ${payload}=    Create Dictionary    username=${username}    password=${password}    remember=true
    ${resp}=    POST On Session    demoblaze    /login
    ...         json=${payload}
    ...         expected_status=200
    ${text}=    Set Variable    ${resp.text}
    ${token}=    Evaluate    str(${text}).strip()
    Should Start With    ${token}    Auth_token:
    [Return]    ${token}

Get Product Entries
    ${resp}=    GET On Session    demoblaze    /entries    expected_status=200
    ${data}=    Evaluate    $resp.json()
    ${items}=   Get From Dictionary    ${data}    Items
    Should Not Be Empty    ${items}
    [Return]    ${items}

*** Test Cases ***
API Flow: Signup, Login, List Products
    Make API Session
    ${rand}=    Generate Random String    8    [LOWER]
    ${u}=       Set Variable    rf_${rand}
    ${p}=       Set Variable    P@ssw0rd!

    # Signup
    ${signup}=    Signup User    ${u}    ${p}

    # Login (expects "Auth_token: <...>")
    ${token}=     Login User     ${u}    ${p}
    Log To Console    Token = ${token}

    # Entries (product list)
    ${items}=     Get Product Entries
    ${count}=    Get Length    ${items}
    Log    Got ${count} items

Check For Specific Item
    Create Session    demoblaze    ${API_BASE}
    ${resp}=    GET On Session    demoblaze    /entries    expected_status=200
    ${data}=    Evaluate    $resp.json()
    ${items}=   Get From Dictionary    ${data}    Items
    ${titles}=    Evaluate    [item['title'] for item in $items]
    List Should Contain Value    ${titles}    Sony vaio i5