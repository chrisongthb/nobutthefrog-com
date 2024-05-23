
// The iframe API will call this function, when the download of the iframe JS code succeeded
// see also loadYoutubeVideo beneath
var player;
function onYouTubeIframeAPIReady() {
  // https://developers.google.com/youtube/iframe_api_reference?hl=de#Loading_a_Video_Player
  player = new YT.Player('yt-video', {
      videoId: 'xDvVn7OpXl4',
      events: {
        'onReady': onPlayerReady,
      }
    }
  );
}

// The API will call this function when the video player is ready.
function onPlayerReady(event) {
  event.target.playVideo();
}

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

  // Load youtube iframeAPI
  function loadYoutubeVideo(){
    const script = document.createElement('script')
    script.src = 'https://www.youtube.com/iframe_api'
    document.head.append(script)
  }
  document.getElementById("showVideoText").addEventListener( 'click', loadYoutubeVideo);
  document.getElementById("showVideoImage").addEventListener( 'click', loadYoutubeVideo);
}

//
// onscroll
//
window.onscroll = function(ev){
  if (window.scrollY > window.innerHeight*0.1) {
    document.getElementById("arrows").classList.add("hidden");
  }
  else {
    document.getElementById("arrows").classList.remove("hidden");
  }
}
