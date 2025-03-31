(function (){
    'use strict';

    angular.module('novaTheme', ['ngMaterial'])
        .provider('novaTheme', ['$mdThemingProvider', function($mdThemingProvider) {
            
            var andsBluePalette = {
                '50': 'f2fafd',
                '100': 'f2fafd',
                '200': 'ddf0f9',
                '300': 'b2ddf1',
                '400': '78c0e5',
                '500': '3ba1d9',
                '600': '387698',
                '700': '366077',
                '800': '354b57',
                '900': '42484B',
                'A700': '3ba1d9'
            };

            var andsRedPalette = {
                '50': 'faccd7',
                '100': 'faccd7',
                '200': 'f699b0',
                '300': 'c92b52',
                '400': 'ed3361',
                '500': 'e9003a',
                '600': 'ad1c3b',
                '700': '8c233d',
                '800': '56212e',
                '900': '473C3E',
                'A700': 'e9003a'
            };

            function setDefaultTheme(){
                var andsBlueMap = $mdThemingProvider.extendPalette('blue', andsBluePalette);
                var andsRedMap = $mdThemingProvider.extendPalette('red', andsRedPalette);

                $mdThemingProvider.definePalette('andsBlue', andsBlueMap);
                $mdThemingProvider.definePalette('andsRed', andsRedMap);

                $mdThemingProvider.theme('default')
                    .primaryPalette('andsBlue')
                    .accentPalette('light-blue')
                    .warnPalette('andsRed');
            }

            this.setTheme = function(theme){
                switch(theme){
                default:
                    setDefaultTheme();
                }
            };        

            this.$get = function() {
                return {};
            };
        }]);
})();