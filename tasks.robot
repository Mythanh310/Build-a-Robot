*** Settings ***
Documentation     Documentation    Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           RPA.Archive
Library           RPA.Dialogs
Library           RPA.Robocorp.Vault
Library           OperatingSystem
Suite Teardown    Close Browser

*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        #Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Close the annoying modal
    Click Button    Yep

Download the file
    [Arguments]    ${address}
    Download    ${address}    overwrite=True
 #    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Get orders
    ${orders} =    Read table from CSV    orders.csv
    [Return]    ${orders}

Fill the form
    [Arguments]    ${row}
    Select From List By Value    head    ${row}[Head]
    Click Element    id-body-${row}[Body]
    Input Text    class:form-control    ${row}[Legs]
    Input Text    address    ${row}[Address]

Preview the robot
    Click Button    preview
    Wait Until Element Is Visible    robot-preview-image

Submit the order
    Sleep    5s
    Click Button When Visible    order
    Wait Until Element Is Visible    receipt

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    ${receipt_html}=    Get Element Attribute    receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}receipt${/}receipt-${order_number}.pdf

Take a screenshot of the robot
    [Arguments]    ${order_number}
    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}robot-${order_number}.png
    Open Pdf    ${OUTPUT_DIR}${/}receipt-${order_number}.pdf
    ${files}=    Create List    ${OUTPUT_DIR}${/}robot-${order_number}.png
    Add Files To Pdf    ${files}    ${OUTPUT_DIR}${/}receipt-${order_number}.pdf    append=True
    Close Pdf

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${order_number}

Go to order another robot
    Wait And Click Button    order-another

Create a ZIP file of the receipts
    # [Arguments]    ${order_number}
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipt    PDFs.zip
