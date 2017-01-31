function get_pref_os() {
  return $('.server-os-prefs input[type="radio"]:checked').val();
}

function get_pref_deploy() {
  return $('.server-deploy-prefs input[type="radio"]:checked').val();
}

function on_pref_os_click(e) {
  $(this).parents("form").submit();
  var pref_deploy = get_pref_deploy();

  // if the deploy prefs buttons are hidden, show them
  // (i.e. .collapse is set, or .collapse.in is NOT set)
  if ($(".server-deploy-prefs.collapse.in").length == 0 && 
      $(".server-deploy-prefs.collapse").length != 0) {
    $(".server-deploy-prefs").collapse("show");
  }
  if (pref_deploy != undefined) {
    draw_deploy_collapse(pref_deploy, this.value);
  }
}

function on_pref_deploy_click() {
  $(this).parents("form").submit();

  var pref_os = get_pref_os()
  var pref_deploy = this.value;

  draw_deploy_collapse(pref_deploy, pref_os);
}

function draw_deploy_collapse(automator, platform) {
  var current_panel = $('#btn-deploy .collapse.in')
  var new_panel = undefined;


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

$(document).on('change', '.server-deploy-prefs input[type="radio"]', on_pref_deploy_click)

$(document).on('change', '.server-os-prefs input[type="radio"]', on_pref_os_click)
