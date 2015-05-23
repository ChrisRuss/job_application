/* Start with global vars to route to office */
var directionsDisplay;
var directionsService;
var geocoder;
var home_point;
var target_address;


/* On opening page, get background data (services, center point etc.) for later usage */
/* target will be defined through back-end and rendered into HTML-view, not as dynamic user input */
function initialize_map(target, map_box, directions_box, error_cb) {

/* Use google geocoder to lookup locations, and  */
  geocoder = new google.maps.Geocoder();
  directionsService = new google.maps.DirectionsService();
  directionsDisplay = new google.maps.DirectionsRenderer();
  target_address = target;
  
  setTarget(target, error_cb, function(cback){
    // Set target = center_point (home_point)
    home_point = cback;
    init_map(map_box,directions_box,cback);
  });
  
}

/* use this function to determine office location, address can be set in back-end */
function setTarget(target, errorcb, cb) {
  
  geocoder.geocode( { 'address': target}, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
          var home_point = results[0].geometry.location;
          cb(home_point);
        } else {
          errorcb(status);
        }
      });
}

/* Initialize map with nice zoom level etc. */
function init_map(map_box, directions_box, center_point){
    
  var mapOptions = {
    zoom:10,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    center: center_point
  }
  
  /* set Div for routing explanation */
  dirbox = document.getElementById(directions_box);
  
  var gmap = new google.maps.Map(document.getElementById(map_box), mapOptions);

  directionsDisplay.setMap(gmap);
  directionsDisplay.setPanel(dirbox);

  var marker = new google.maps.Marker({
      map: gmap,
      position: center_point
  });
  
}

/* Wrapped Google routing service to lookup route from given address to office location */
function calcRoute(start, error_call, success_call) {

  var directionsRequest = {
    origin: start,
    destination: target_address,
    travelMode: google.maps.DirectionsTravelMode.DRIVING,
    unitSystem: google.maps.UnitSystem.METRIC
  };
  directionsService.route(directionsRequest, function(response, status) {
    if (status == google.maps.DirectionsStatus.OK) {
      success_call();
      directionsDisplay.setDirections(response);
    } else {
      error_call();
    }
  });
}