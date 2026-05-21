# EarthBroker Clone — Yellow Pages Style Directory

## Project Structure

```
earthbroker-clone/
  index.html                        # Homepage
  pwa-manifest.json                 # PWA manifest
  assets/
    css/
      style.css                     # Main stylesheet (Yellow Pages style)
      responsive.css                # Responsive/media query overrides
    js/
      jquery-3.7.1.min.js           # jQuery dependency
      main.js                       # Core functionality (rendering, sorting, filtering, PWA)
      data.js                       # Sample listing and category data
    images/                         # Placeholder images
    fonts/                          # Web fonts
  includes/
    header.html                     # Reusable header template
    footer.html                     # Reusable footer template
  pages/
    index.html                      # (root is home)
    about/index.html                # About page
    classifieds/index.html          # Classifieds listing page (with sidebar filters)
    business-directory/index.html   # Business directory (Yellow Pages style)
    digital-magazine/index.html     # Digital magazine archive
    advertisers-index/index.html    # Advertisers index with A-Z filter
    featured-business/index.html    # Featured businesses
    listing-category/index.html     # Category filtered listings
    listing-detail/index.html       # Single listing detail view
    contact/index.html              # Contact & subscribe form
  admin/                            # Admin panel placeholder
```

## Tech Stack (Clone)
- HTML5 + CSS3 (no build tools)
- jQuery 3.7.1
- JSON data layer (data.js)
- PWA ready (manifest.json + install prompt)
- Fully responsive

## Original Site Analysis

| Feature | Original | Clone |
|---------|----------|-------|
| CMS | WordPress + Divi 4.27.6 | Static HTML |
| Directory Plugin | Business Directory Plugin (WPBDP) 6.4.24 | Custom JS data layer |
| SEO | All in One SEO 4.9.7.2 | Manual meta tags |
| Analytics | MonsterInsights (GA4) | - |
| Forms | Formidable Forms | HTML5 forms |
| Slider | MetaSlider | CSS only |
| Mega Menu | Max Mega Menu | CSS nav |
| Cookie Consent | NSC Cookie Consent | - |
| PWA | Yes | Yes |
| Hosting | DataKeepers (160.119.100.226) | Any static host |

## Yellow Pages Conversion Feasibility

**YES** — The site is an excellent candidate for Yellow Pages / index-style conversion:

1. Already has categorized listings (Earthmoving Machinery, Spares, etc.)
2. Existing Business Directory page with category buttons
3. Advertisers Index with alphabetical listing
4. Can add:
   - Business name, address, phone, email, website per listing
   - Category-based browsing (A-Z by business name)
   - Search by location, category, keyword
   - Promoted/featured business placements
   - Map integration for location-based search

## How to Use
Open `index.html` in any browser. All pages are linked. Data is loaded from `assets/js/data.js`. Listing detail pages use URL params (`?id=N`).

## GitHub Pages Deployment

### One-time setup (install Git + GitHub CLI)
```powershell
# 1. Download Git from https://git-scm.com/download/win
# 2. Download GitHub CLI from https://cli.github.com/
# 3. Restart PowerShell, then:

git --version
gh --version
gh auth login
```

### Deploy to GitHub Pages
```powershell
cd C:\Users\GadliNet5\earthbroker-clone

git init
git add .
git commit -m "Initial commit - EarthBroker clone prototype"

gh repo create earthbroker-clone --public --source=. --remote=origin --push
```

### Enable GitHub Pages
1. Go to `https://github.com/YOUR_USERNAME/earthbroker-clone/settings/pages`
2. Under "Source", select "Deploy from a branch"
3. Select `main` branch and `/ (root)` folder
4. Click Save
5. Your site will be live at: `https://YOUR_USERNAME.github.io/earthbroker-clone/`

### Or deploy to any static host
Upload the entire `earthbroker-clone/` folder to any web server, Netlify, Vercel, Cloudflare Pages, etc. No build step needed — just serve the static files.

## SEO Recommendations
1. Add proper hreflang tags for multi-region
2. Generate XML sitemap
3. Add structured data (schema.org/Product for listings)
4. Implement server-side rendering for listing pages
5. Add lazy loading for images
6. Compress and optimize all images
7. Add Open Graph tags for social sharing
8. Set up canonical URLs properly
