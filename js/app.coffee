##
# Angular: module
#
module = angular.module 'BowerPackages', []

##
# Controller
#
module.controller 'IndexController', [
  '$scope',
  '$http'
  '$location'
  '$window'
  ($scope, $http, $location, $window) ->

    ##
    # Data
    #
    items = []

    matchedResults = []

    $scope.results = []

    ##
    # Pagination
    #
    $scope.q = ''

    $scope.qParams =
      keyword: null
      owner: null

    $scope.sortField = 'stars'

    $scope.sortReverse = true

    $scope.limit = 30

    $scope.page = 1

    $scope.count = 0

    $scope.pagesCount = 1


    ##
    # Operations
    #
    matchesByName = (item) ->
      if item.name.indexOf($scope.qParams.keyword.toLowerCase()) > -1
        return true

      false

    matchesByKeyword = (item) ->
      if item.keywords? and item.keywords.length > 0
        for k, keyword of item.keywords
          if keyword.toLowerCase().indexOf($scope.qParams.keyword.toLowerCase()) > -1
            return true

      false

    matchesByOwner = (item) ->
      if !$scope.qParams.owner? or $scope.qParams.owner.length is 0
        return true

      if item.owner? and item.owner.length > 0
        if item.owner.toLowerCase().indexOf($scope.qParams.owner.toLowerCase()) > -1
            return true

      false

    find = () ->
      matchedResults = _.filter items, (item) ->
        if $scope.q.length is 0
          return true

        if (matchesByName(item) or matchesByKeyword(item)) and matchesByOwner(item)
          return true

        false

    sort = () ->
      matchedResults = _.sortBy matchedResults, (item) ->
        item[$scope.sortField]

      if $scope.sortReverse
        matchedResults = matchedResults.reverse()

    limit = () ->
      from           = ($scope.page - 1) * $scope.limit
      $scope.results = _.clone(matchedResults).splice from, $scope.limit

    count = () ->
      $scope.count      = matchedResults.length
      $scope.pagesCount = Math.ceil($scope.count / $scope.limit)


    ##
    # Search
    #
    $scope.refresh = () ->
      $scope.search()

    $scope.search = () ->
      if $scope.loading
        return false

      keywords = []
      owner    = null
      for k, v of $scope.q.split ' '
        if v.indexOf('owner:') is 0
          owner = v.replace 'owner:', ''
        else
          keywords.push v

      $scope.qParams =
        keyword: keywords.join ' '
        owner: owner

      $scope.page = 1
      $location.search
        q: $scope.q

      find()
      sort()
      limit()
      count()

    $scope.sortResults = (field) ->
      if $scope.sortField is field
        $scope.sortReverse = !$scope.sortReverse
      else
        $scope.sortReverse = false

      $scope.sortField = field
      sort()
      limit()

    $scope.goToPrev = () ->
      if $scope.hasPrev()
        $scope.page--
        limit()

    $scope.goToNext = () ->
      if $scope.hasNext()
        $scope.page++
        limit()

    ##
    # Checkers
    #
    $scope.hasPrev = () ->
      if $scope.page is 1
        return false

      true

    $scope.hasNext = () ->
      if $scope.page is $scope.pagesCount
        return false

      true


    ##
    # Formatters
    #
    $scope.formatDate = (timestamp) ->
      moment(timestamp).fromNow()


    ##
    # Key bindings for prev/next
    #
    angular.element($window).on 'keydown', (e) ->
      if document?.activeElement?.id is 'q'
        return true

      if e.keyCode is 37
        if !$scope.$$phase
          $scope.$apply ->
            $scope.goToPrev()
      else if e.keyCode is 39
        if !$scope.$$phase
          $scope.$apply ->
            $scope.goToNext()

    ##
    # Init
    #
    $scope.loading      = true
    $scope.loadingError = false
    url                 = 'https://bower-component-list.herokuapp.com/'

    promise = $http.get url
    promise.then (res) ->
      if res.status isnt 200
        $scope.loadingError = true
        return false

      items = res.data
      $scope.loading = false

      urlParams = $location.search()
      if urlParams?.q?
        $scope.q = urlParams.q

      $scope.refresh()

]
