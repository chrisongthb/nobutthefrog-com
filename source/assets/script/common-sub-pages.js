//
// onload
//
window.onload = function () {
  // Menu Button click
  function toggle_show_menu_items() {
    document.getElementById("myTopnav").classList.toggle("showitems");
    document.getElementById("menu-icon-bars-container").classList.toggle("showitems");
  }
  document.getElementById("menu-icon").addEventListener( 'click', toggle_show_menu_items);
}
