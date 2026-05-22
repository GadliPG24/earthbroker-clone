(function($) {
  $(document).ready(function() {
    // Mobile menu toggle
    $('.mobile-toggle').on('click', function() {
      $('#top-menu').toggleClass('open');
    });

    // Render listing cards
    function renderListings(data, container, limit) {
      var html = '';
      var items = limit ? data.slice(0, limit) : data;
      items.forEach(function(item) {
        var imgSrc = item.image ? IMG_BASE + item.image : '';
        var imgHtml = item.image
          ? '<img src="' + imgSrc + '" alt="' + item.title + '" class="listing-img" />'
          : '<div class="listing-img">' + item.title.charAt(0) + '</div>';
        var priceHtml = item.price ? '<div class="listing-price">' + item.price + '</div>' : '';
        html += '<div class="listing-card">'
          + '<a href="../listing-detail/index.html?id=' + item.id + '">' + imgHtml + '</a>'
          + '<div class="listing-body">'
          + '<h3 class="listing-title"><a href="../listing-detail/index.html?id=' + item.id + '">' + item.title + '</a></h3>'
          + '<div class="listing-meta">' + item.category + ' / ' + item.views + ' views</div>'
          + priceHtml
          + '</div></div>';
      });
      if (container) container.html(html);
      return html;
    }

    // Home page listings
    if ($('#home-listings').length) {
      renderListings(EB_DATA.listings, $('#home-listings'), 6);
    }

    // Classifieds page
    if ($('#classifieds-listings').length) {
      renderListings(EB_DATA.listings, $('#classifieds-listings'));

      // Sorting
      $('#sort-by').on('change', function() {
        var val = $(this).val();
        var sorted = [].concat(EB_DATA.listings);
        if (val === 'title-asc') sorted.sort(function(a,b) { return a.title.localeCompare(b.title); });
        else if (val === 'title-desc') sorted.sort(function(a,b) { return b.title.localeCompare(a.title); });
        else if (val === 'recent') sorted.sort(function(a,b) { return b.id - a.id; });
        else if (val === 'oldest') sorted.sort(function(a,b) { return a.id - b.id; });
        else if (val === 'views') sorted.sort(function(a,b) { return b.views - a.views; });
        else if (val === 'views-low') sorted.sort(function(a,b) { return a.views - b.views; });
        else if (val === 'price-low') sorted.sort(function(a,b) { return (a.price ? parseFloat(a.price.replace(/[^0-9.]/g,'')) : 999999) - (b.price ? parseFloat(b.price.replace(/[^0-9.]/g,'')) : 999999); });
        else if (val === 'price-high') sorted.sort(function(a,b) { return (b.price ? parseFloat(b.price.replace(/[^0-9.]/g,'')) : 0) - (a.price ? parseFloat(a.price.replace(/[^0-9.]/g,'')) : 0); });
        renderListings(sorted, $('#classifieds-listings'));
        if (typeof updateResultsCount === 'function') updateResultsCount(sorted.length);
      });

      // Category filter
      $('#filter-category').on('change', function() {
        var cat = $(this).val();
        var filtered = cat ? EB_DATA.listings.filter(function(l) { return l.category === cat; }) : EB_DATA.listings;
        renderListings(filtered, $('#classifieds-listings'));
        if (typeof updateResultsCount === 'function') updateResultsCount(filtered.length);
      });
    }

    // Business directory page
    if ($('#directory-listings').length) {
      renderListings(EB_DATA.listings, $('#directory-listings'));
      $('#dir-category-filter').on('change', function() {
        var cat = $(this).val();
        var filtered = cat ? EB_DATA.listings.filter(function(l) { return l.category === cat; }) : EB_DATA.listings;
        renderListings(filtered, $('#directory-listings'));
      });
    }

    // Results count update
    window.updateResultsCount = function(count) {
      $('.results-count').text(count + ' item(s) found');
    };
    if ($('.results-count').length) {
      updateResultsCount(EB_DATA.listings.length);
    }

    // View toggle
    $('.view-toggle button').on('click', function() {
      $('.view-toggle button').removeClass('active');
      $(this).addClass('active');
      var view = $(this).data('view');
      var grid = $('#classifieds-listings, #directory-listings, #home-listings');
      if (view === 'list') { grid.removeClass('listings-grid').addClass('listings-list'); }
      else { grid.removeClass('listings-list').addClass('listings-grid'); }
    });

    // PWA install banner
    var pwaBanner = $('#pwa-install-banner');
    var deferredPrompt;
    window.addEventListener('beforeinstallprompt', function(e) {
      e.preventDefault();
      deferredPrompt = e;
      pwaBanner.removeClass('hidden');
    });
    $('#install-pwa').on('click', function() {
      if (deferredPrompt) {
        deferredPrompt.prompt();
        deferredPrompt.userChoice.then(function() { deferredPrompt = null; });
      }
      pwaBanner.addClass('hidden');
    });
    $('#close-pwa-banner').on('click', function() {
      pwaBanner.addClass('hidden');
    });
  });
})(jQuery);
