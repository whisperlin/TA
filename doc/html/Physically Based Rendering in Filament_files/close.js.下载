var _hmt = _hmt || [];
(function() {
    var hm = document.createElement("script");
    hm.src = "//hm.baidu.com/hm.js?8875c662941dbf07e39c556c8d97615f";
    var s = document.getElementsByTagName("script")[0];
    s.parentNode.insertBefore(hm, s);
})();

function closeFrame(){
    var parent_url = document.getElementById('src').value;
    croDomain.postMessage('close',parent_url);
    return false;
 }
 var isTag = document.getElementById('ydNoteWebClipper');
document.getElementById('close').onclick = function() {
    if(isTag){
        window._hmt.push(['_trackEvent', 'close-frame-tag', 'click']);
    }else{
        window._hmt.push(['_trackEvent', 'close-frame-extention', 'click']);
    }
     closeFrame();
 };
var cancelbtn = document.getElementById('cancelbtn');
if (cancelbtn) {
    cancelbtn.onclick = function() {
        if(isTag){
            window._hmt.push(['_trackEvent', 'click-cancel-tag', 'click']);
        }else{
            window._hmt.push(['_trackEvent', 'click-cancel-extention', 'click']);
        }
        closeFrame();
    };
}
