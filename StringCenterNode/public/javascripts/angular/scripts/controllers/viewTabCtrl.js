angular.module('stringCenter').controller('viewTabCtrl', function($scope, viewTabService){
    $scope.tab = viewTabService.getViewedTab()[0];
    console.log($scope.tab);
});
