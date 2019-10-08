function Controller() {
    installer.autoRejectMessageBoxes();
    installer.setMessageBoxAutomaticAnswer("installationErrorWithRetry", QMessageBox.Ignore);
    installer.setMessageBoxAutomaticAnswer("installationError", QMessageBox.Ignore);
    installer.installationFinished.connect(function() {
        gui.clickButton(buttons.NextButton);
    });
}

Controller.prototype.WelcomePageCallback = function() {
    // click delay here because the next button is initially disabled for ~1 second
    gui.clickButton(buttons.NextButton, 10000);
}

Controller.prototype.CredentialsPageCallback = function() {
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.IntroductionPageCallback = function() {
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.DynamicTelemetryPluginFormCallback = function() {
    var widget = gui.currentPageWidget();
    widget.TelemetryPluginForm.statisticGroupBox.disableStatisticRadioButton.checked = true;
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.TargetDirectoryPageCallback = function() {
    gui.currentPageWidget().TargetDirectoryLineEdit.setText("D:\\qt");
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.ComponentSelectionPageCallback = function() {
    var widget = gui.currentPageWidget();

    widget.deselectAll();
    widget.selectComponent("qt.qt5.5131.win64_mingw73");
    widget.selectComponent("qt.tools.win64_mingw730");

    gui.clickButton(buttons.NextButton);
}

Controller.prototype.LicenseAgreementPageCallback = function() {
    gui.currentPageWidget().AcceptLicenseRadioButton.setChecked(true);
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.StartMenuDirectoryPageCallback = function() {
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.ReadyForInstallationPageCallback = function()
{
    gui.clickButton(buttons.NextButton);
}

Controller.prototype.FinishedPageCallback = function() {
    var checkBoxForm = gui.currentPageWidget().LaunchQtCreatorCheckBoxForm;
    if (checkBoxForm && checkBoxForm.launchQtCreatorCheckBox) {
        checkBoxForm.launchQtCreatorCheckBox.checked = false;
    }
    gui.clickButton(buttons.FinishButton);
}