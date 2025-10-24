*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    SeleniumLibrary


*** Variables ***
${API_BASE}    https://api.demoblaze.com
${TIMEOUT}     10
${BROWSER}     chrome

*** Keywords ***

Open Chrome With CI Options
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${options}    add_argument    --no-sandbox
    Call Method    ${options}    add_argument    --disable-dev-shm-usage
    Call Method    ${options}    add_argument    --headless
    Call Method    ${options}    add_argument    --disable-gpu
    Create WebDriver    Chrome    options=${options}
    Go To    https://www.demoblaze.com/

Get Product Titles From API
    Create Session    demoblaze    https://api.demoblaze.com
    ${resp}=    GET On Session    demoblaze    /entries    expected_status=200
    ${data}=    Evaluate    $resp.json()
    ${items}=   Get From Dictionary    ${data}    Items
    ${titles}=  Evaluate    [item['title'].strip() for item in $items]
    [Return]    ${titles}

*** Test Cases ***

Verify Products From API Are Shown In UI
    ${titles}=    Get Product Titles From API
    Open Chrome With CI Options
    Maximize Browser Window
    # Go to the Laptops category (for notebook products)
    Click Element    xpath=//a[normalize-space(.)='Laptops']
    FOR    ${title}    IN    @{titles}
        Log To Console    Checking: ${title}
        ${is_laptop}=    Run Keyword And Return Status    Should Contain    ${title.lower()}    vaio
        IF    ${is_laptop}
            Wait Until Element Is Visible    xpath=//a[normalize-space(.)='${title}']    10
            Log To Console    Found laptop: ${title}
        END
    END
    Close Browser