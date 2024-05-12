---
layout: sub-page
---

      <h1>Aktuelles</h1>
      <p>TODO: content, bandcamp shop "merch" section einrichten</p>
      <div id="main-content-button-container"> <!--- This is needed to force <a > to respect parent's boarders -->
        <a id="main-content-button-link" target="_blank" href="https://nobutthefrog.bandcamp.com/">
          <p id="main-content-button-text">Besuche unseren Shop</p>
        </a>
      </div>

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>
