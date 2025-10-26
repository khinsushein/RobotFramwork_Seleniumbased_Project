*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary
Library    Collections

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
    Create WebDriver    Chrome    executable_path=${driver_path}    options=${options}
    Go To    https://www.demoblaze.com/

Get Phone Titles From API
    Create Session    demoblaze    ${API_BASE}
    ${resp}=    GET On Session    demoblaze    /entries    expected_status=200
    ${data}=    Evaluate    $resp.json()
    ${items}=   Get From Dictionary    ${data}    Items
    # Keep only phones (API cat is 'phone')
    ${phones}=    Evaluate    [i for i in $items if str(i.get('cat','')).lower() == 'phone']
    ${titles}=     Evaluate    sorted({ i['title'].strip() for i in $phones })
    [RETURN]    ${titles}

Open Demoblaze And Go To Phones
    Open Browser    https://www.demoblaze.com/    ${BROWSER}
    Maximize Browser Window
    Wait Until Page Contains Element    css=#tbodyid .card-title a    ${TIMEOUT}
    Click Element    xpath=//a[normalize-space(.)='Phones']
    Wait Until Page Contains Element    css=#tbodyid .card-title a    ${TIMEOUT}

Collect All UI Titles In Phones
    ${seen}=    Create List
    ${stall}=   Set Variable    0
    WHILE    ${stall} < 2
        ${page}=   Create List
        # Fetch elements fresh each loop iteration
        ${els}=    Get WebElements    css=#tbodyid .card-title a
        FOR    ${el}    IN    @{els}
            ${t}=      Get Text    ${el}
            Append To List    ${page}    ${t.strip()}
        END
        ${before}=    Get Length    ${seen}
        ${seen}=      Evaluate    list(sorted(set($seen) | set($page)))
        ${after}=     Get Length    ${seen}
        ${stall}=     Set Variable    ${${after} <= ${before} and ${stall}+1 or 0}
        ${has_next}=  Run Keyword And RETURN Status    Page Should Contain Element    id=next2
        Run Keyword If    not ${has_next}    Exit For Loop
        ${is_visible}=   Run Keyword And RETURN Status    Element Should Be Visible    id=next2
        Run Keyword If    not ${is_visible}    Exit For Loop
        ${is_enabled}=   Run Keyword And RETURN Status    Element Should Be Enabled    id=next2
        Run Keyword If    not ${is_enabled}    Exit For Loop
        Scroll Element Into View    id=next2
        Sleep    2s
        Wait Until Element Is Visible    id=next2    ${TIMEOUT}
        Wait Until Element Is Enabled    id=next2    ${TIMEOUT}
        Click Element    id=next2
        Sleep    1s
        Wait Until Page Contains Element    css=#tbodyid .card-title a    ${TIMEOUT}
        # Do NOT use previously fetched elements after clicking "Next"
    END
    [RETURN]    ${seen}

Assert API Phones Are In UI
    [Arguments]    ${api_titles}    ${ui_titles}
    ${missing}=    Evaluate    sorted(list(set($api_titles) - set($ui_titles)))
    Log    UI titles: ${ui_titles}
    Log    API titles: ${api_titles}
    Should Be Empty    ${missing}    Missing from UI: ${missing}

*** Test Cases ***
Verify Phone Products From API Are Shown In UI
    ${api_titles}=    Get Phone Titles From API
    Open Demoblaze And Go To Phones
    ${ui_titles}=     Collect All UI Titles In Phones
    Assert API Phones Are In UI    ${api_titles}    ${ui_titles}
    Close Browser

