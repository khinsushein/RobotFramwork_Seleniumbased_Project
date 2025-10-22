*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}     https://www.demoblaze.com/

*** Test Cases ***
Open demoblaze and perform actions
    Open Browser    ${URL}    chrome
    Click Element   //button[contains(text(),"Log in")]
    Input Text      //input[@name="username"]    myuser
    Close Browser