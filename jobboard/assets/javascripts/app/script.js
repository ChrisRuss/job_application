$.noConflict();

/* Define vCard invisble starting points for animation */
var pullRightStart = "200px";
var contactRight = "-250px";
var pullRightStop = "-50px";


jQuery(document).ready(function($) {
    
    /* on viewing site with a team member, float in details and picture */
    $(".teammember .details").animate({left: "0px", opacity: "1"}, 1500);
    $(".photo").animate({right: "140px", opacity: "1"}, 1500);
  
    /* Permanent contact box on side, click should let it slide in and open */
    /* Grab sidebox and "activation button" to add functionality */
    var contact = $('#contact_side_box');
    var pullContact = $('a.pull_contact');
    /* little hack to fit for IE */
    if ($.browser.msie && parseInt($.browser.version, 10)<=9) {
      pullRightStart = "250px";
      contactRight = "-250px";
      pullRightStop = "0px"
    }
    
    
    pullContact.stop().toggle(function(){
      /* define behavior on box activation, set to active for visibility */
            contact.stop().show();
            pullContact.toggleClass("active", 2000);
            contact.stop().animate({right:"0px"}, 800);
            pullContact.stop().animate({right:pullRightStart}, 800);
            return false;
        },
      /* define behavior on box deactivation, disable active (for css) */
        function(){
            contact.stop().animate({right:contactRight}, 800, function(){
                contact.stop().hide();
                pullContact.toggleClass("active", 2000);
            });
            pullContact.stop().animate({right:pullRightStop}, 800);
            return false;
        }
    );
     
});