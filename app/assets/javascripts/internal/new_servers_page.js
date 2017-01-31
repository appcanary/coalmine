function getPrefOS() {
  return $('.server-os-prefs input[type="radio"]:checked').val();
}

function getPrefDeploy() {
  return $('.server-deploy-prefs input[type="radio"]:checked').val();
}

function onPrefOSClick(e) {
  $(this).parents("form").submit();
  var pref_deploy = getPrefDeploy();

  // if the deploy prefs buttons are hidden, show them
  // (i.e. .collapse is set, or .collapse.in is NOT set)
  if ($(".server-deploy-prefs.collapse.in").length == 0 && 
      $(".server-deploy-prefs.collapse").length != 0) {
    $(".server-deploy-prefs").collapse("show");
  }
  if (pref_deploy != undefined) {
    drawDeployCollapse(pref_deploy, this.value);
  }
}

function onPrefDeployClick() {
  $(this).parents("form").submit();

  var pref_os = getPrefOS()
  var pref_deploy = this.value;

  drawDeployCollapse(pref_deploy, pref_os);
}

function drawDeployCollapse(automator, platform) {
  var current_panel = $('#btn-deploy .collapse.in');
  var new_panel = undefined;

  // the shell deploy box displays diff content
  // if a .deb or .rpm system is selected
  if (automator != "shell") {
    new_panel = $('#deploy-'+automator);

  } else {
    new_panel = $('#deploy-'+automator+"."+platform);
  }

  if (current_panel[0] != new_panel[0]) {
    $('#btn-deploy .collapse.in').collapse('hide');
    new_panel.collapse('show');
  }
}

$(document).on('change', '.server-deploy-prefs input[type="radio"]', onPrefDeployClick);
$(document).on('change', '.server-os-prefs input[type="radio"]', onPrefOSClick);
