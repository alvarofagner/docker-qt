function log() {
  var msg = ["LOG: "].concat([].slice.call(arguments));
  console.log(msg.join(" "));
}

function Controller() {
  installer.autoRejectMessageBoxes();
  installer.installationFinished.connect(function() {
    gui.clickButton(buttons.NextButton);
  })
}

Controller.prototype.WelcomePageCallback = function() {
  log("Welcome Page");
  gui.clickButton(buttons.NextButton, 3000);
}

Controller.prototype.CredentialsPageCallback = function() {
  log("Credentials Page");
  var login = installer.environmentVariable("QT_CI_LOGIN");
  var password = installer.environmentVariable("QT_CI_PASSWORD");
  if (login === "" || password === "") {
      gui.clickButton(buttons.CommitButton);
  }

  log("Has login and password")

  var widget = gui.currentPageWidget();
  widget.loginWidget.EmailLineEdit.setText(login);
  widget.loginWidget.PasswordLineEdit.setText(password);
  gui.clickButton(buttons.CommitButton);
}

Controller.prototype.ObligationsPageCallback = function() {
  log("Obligation Page");
  var widget = gui.currentPageWidget();
  widget.obligationsAgreement.setChecked(true);
  widget.completeChanged();
  gui.clickButton(buttons.NextButton);
}

Controller.prototype.IntroductionPageCallback = function() {
  log("Introduction Page");
  gui.clickButton(buttons.NextButton);
}

Controller.prototype.TargetDirectoryPageCallback = function() {
  log("Target Directory");
  var folder = installer.environmentVariable("QT_INSTALLATION_FOLDER");
  gui.currentPageWidget().TargetDirectoryLineEdit.setText(folder);
  gui.clickButton(buttons.NextButton);
}

Controller.prototype.ComponentSelectionPageCallback = function() {
  log("Component Selection Page");
  var widget = gui.currentPageWidget();

  var qtVersion = installer.environmentVariable("QT_COMPONENT_VERSION");

  widget.deselectAll();
  widget.selectComponent("qt.qt5." + qtVersion + ".gcc_64");
  widget.selectComponent("qt.qt5." + qtVersion + ".android");
  widget.selectComponent("qt.qt5." + qtVersion + ".qtscript");
  widget.selectComponent("qt.qt5." + qtVersion + ".qtwebengine");
  widget.selectComponent("qt.tools.qtcreator");

  gui.clickButton(buttons.NextButton);
}

Controller.prototype.LicenseAgreementPageCallback = function() {
  log("License Aggreement");
  gui.currentPageWidget().AcceptLicenseRadioButton.setChecked(true);
  gui.clickButton(buttons.NextButton);
}

Controller.prototype.StartMenuDirectoryPageCallback = function() {
  log("Start Menu Directory");
  gui.clickButton(buttons.NextButton);
}

Controller.prototype.ReadyForInstallationPageCallback = function()
{
  log("Installation Page");
  gui.clickButton(buttons.NextButton);
}

Controller.prototype.FinishedPageCallback = function() {
  log("Finished Page");
  var checkBoxForm = gui.currentPageWidget().LaunchQtCreatorCheckBoxForm
  if (checkBoxForm && checkBoxForm.launchQtCreatorCheckBox) {
    checkBoxForm.launchQtCreatorCheckBox.checked = false;
  }
  gui.clickButton(buttons.FinishButton);
}
