(function(angular) {
  'use strict';
function ChevronController() {

}

angular.module('ChevronApp').component('ngChevron', {
  templateUrl: '{!envPath}/partials/ngChevron.html',
  controller: ChevronController,
  bindings: {
    chevronconfig: '='
  }
});
})(window.angular);