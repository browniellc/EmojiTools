function Show-EmojiPicker {
    <#
    .SYNOPSIS
        Opens an interactive emoji picker interface.
    
    .DESCRIPTION
        Launches an interactive HTML-based emoji picker in your default browser.
        Features include real-time search, category filtering, skin tone selection,
        and automatic clipboard integration.
    
    .PARAMETER Category
        Pre-filter to a specific emoji category
    
    .PARAMETER Theme
        Visual theme for the picker. Valid values: Light, Dark, Auto (default: Auto)
    
    .PARAMETER ReturnEmoji
        Return the selected emoji to the pipeline instead of copying to clipboard
    
    .PARAMETER Port
        HTTP server port (default: 8321). Change if port is already in use.
    
    .PARAMETER Standalone
        Open as standalone HTML page without server communication.
        In this mode, emojis are copied to clipboard but no value is returned to PowerShell.
        You must manually close the browser window.
    
    .EXAMPLE
        Show-EmojiPicker
        Opens the emoji picker with auto-detection of system theme
    
    .EXAMPLE
        Show-EmojiPicker -Category "Smileys & Emotion"
        Opens picker pre-filtered to smileys
    
    .EXAMPLE
        $emoji = Show-EmojiPicker -ReturnEmoji
        Select an emoji and return it to a variable
    
    .EXAMPLE
        Show-EmojiPicker -Theme Dark
        Open picker with dark theme
    
    .EXAMPLE
        Show-EmojiPicker -Standalone
        Open as standalone page (no server, manual close)
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Category,
        
        [Parameter(Mandatory = $false)]
        [string]$Collection,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Light', 'Dark', 'Auto')]
        [string]$Theme = 'Auto',
        
        [Parameter(Mandatory = $false)]
        [switch]$ReturnEmoji,
        
        [Parameter(Mandatory = $false)]
        [int]$Port = 8321,
        
        [Parameter(Mandatory = $false)]
        [switch]$Standalone
    )
    
    # Load emoji data
    $datasetPath = Join-Path $PSScriptRoot "..\data\emoji.csv"
    
    if (-not (Test-Path $datasetPath)) {
        Write-Error "Emoji dataset not found at $datasetPath"
        return
    }
    
    $emojis = Import-Csv -Path $datasetPath -Encoding UTF8
    
    # Load collections for display
    $collectionsPath = Join-Path $PSScriptRoot "..\data\collections.json"
    $collectionsData = @{}
    if (Test-Path $collectionsPath) {
        $collectionsData = Get-Content $collectionsPath -Encoding UTF8 | ConvertFrom-Json -AsHashtable
    }
    
    # Filter by collection if specified via parameter
    if ($Collection) {
        if (-not $collectionsData.ContainsKey($Collection)) {
            Write-Error "Collection '$Collection' not found. Run Get-EmojiCollection to see available collections."
            return
        }
        
        $collectionEmojis = $collectionsData[$Collection].emojis
        $emojis = $emojis | Where-Object { $collectionEmojis -contains $_.emoji }
        Write-Host "🎨 Filtering to '$Collection' collection ($($emojis.Count) emojis)" -ForegroundColor Cyan
    }
    
    # Convert ALL emojis to JSON for JavaScript (don't filter here, let JS handle it)
    $emojiArray = @($emojis | ForEach-Object {
            @{
                emoji = $_.emoji
                name = $_.name
                keywords = $_.keywords
                category = $_.category
            }
        })
    $emojiJson = ($emojiArray | ConvertTo-Json -Compress -Depth 10)
    
    # Get unique categories from ALL emojis
    $categories = $emojis | Where-Object { $_.category } | 
        Select-Object -ExpandProperty category -Unique | 
        Sort-Object
    
    $categoriesJson = (@($categories) | ConvertTo-Json -Compress)
    
    # Convert collections to JSON for JavaScript
    $collectionsForJs = @{}
    foreach ($key in $collectionsData.Keys) {
        $collectionsForJs[$key] = $collectionsData[$key].emojis
    }
    $collectionsJson = ($collectionsForJs | ConvertTo-Json -Compress -Depth 10)
    
    # Determine theme
    $themeClass = switch ($Theme) {
        'Light' { 'theme-light' }
        'Dark' { 'theme-dark' }
        'Auto' { 'theme-auto' }
    }
    
    # Generate HTML content
    $html = @"
<!DOCTYPE html>
<html lang="en" class="$themeClass">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🎭 Emoji Picker - EmojiTools</title>
    <style>
        :root {
            --bg-primary: #ffffff;
            --bg-secondary: #f8f9fa;
            --bg-hover: #e9ecef;
            --text-primary: #212529;
            --text-secondary: #6c757d;
            --border-color: #dee2e6;
            --accent-color: #667eea;
            --accent-hover: #5a67d8;
            --shadow: rgba(0, 0, 0, 0.1);
        }
        
        .theme-dark,
        .theme-auto {
            --bg-primary: #1e1e1e;
            --bg-secondary: #2d2d2d;
            --bg-hover: #3a3a3a;
            --text-primary: #e0e0e0;
            --text-secondary: #a0a0a0;
            --border-color: #404040;
            --accent-color: #7c3aed;
            --accent-hover: #6d28d9;
            --shadow: rgba(0, 0, 0, 0.3);
        }
        
        @media (prefers-color-scheme: light) {
            .theme-auto {
                --bg-primary: #ffffff;
                --bg-secondary: #f8f9fa;
                --bg-hover: #e9ecef;
                --text-primary: #212529;
                --text-secondary: #6c757d;
                --border-color: #dee2e6;
                --accent-color: #667eea;
                --accent-hover: #5a67d8;
                --shadow: rgba(0, 0, 0, 0.1);
            }
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            line-height: 1.6;
            height: 100vh;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        
        .header {
            background: var(--bg-secondary);
            padding: 15px 20px;
            border-bottom: 2px solid var(--border-color);
            display: flex;
            align-items: center;
            gap: 15px;
            flex-shrink: 0;
        }
        
        .header h1 {
            font-size: 1.5em;
            font-weight: 600;
            margin: 0;
        }
        
        .search-container {
            flex: 1;
            max-width: 500px;
        }
        
        .search-box {
            width: 100%;
            padding: 10px 15px;
            font-size: 16px;
            border: 2px solid var(--border-color);
            border-radius: 8px;
            background: var(--bg-primary);
            color: var(--text-primary);
            transition: border-color 0.2s;
        }
        
        .search-box:focus {
            outline: none;
            border-color: var(--accent-color);
        }
        
        .search-box::placeholder {
            color: var(--text-secondary);
        }
        
        .stats {
            color: var(--text-secondary);
            font-size: 0.9em;
        }
        
        .categories {
            background: var(--bg-secondary);
            padding: 10px 20px;
            border-bottom: 1px solid var(--border-color);
            overflow-x: auto;
            white-space: nowrap;
            flex-shrink: 0;
        }
        
        .category-btn {
            display: inline-block;
            padding: 8px 16px;
            margin-right: 8px;
            background: var(--bg-primary);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            cursor: pointer;
            font-size: 0.9em;
            transition: all 0.2s;
            color: var(--text-primary);
        }
        
        .category-btn:hover {
            background: var(--bg-hover);
            transform: translateY(-2px);
        }
        
        .category-btn.active {
            background: var(--accent-color);
            color: white;
            border-color: var(--accent-color);
        }
        
        .content {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
        }
        
        .emoji-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(70px, 1fr));
            gap: 8px;
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .emoji-item {
            aspect-ratio: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 10px;
            background: var(--bg-secondary);
            border: 2px solid transparent;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.2s;
            position: relative;
        }
        
        .emoji-item:hover {
            background: var(--bg-hover);
            border-color: var(--accent-color);
            transform: scale(1.1);
            z-index: 10;
        }
        
        .emoji-symbol {
            font-size: 2em;
            user-select: none;
        }
        
        .emoji-item:hover .emoji-tooltip {
            opacity: 1;
            visibility: visible;
        }
        
        .emoji-tooltip {
            position: absolute;
            bottom: 100%;
            left: 50%;
            transform: translateX(-50%);
            background: var(--bg-primary);
            border: 1px solid var(--border-color);
            padding: 8px 12px;
            border-radius: 8px;
            font-size: 0.8em;
            white-space: nowrap;
            opacity: 0;
            visibility: hidden;
            transition: opacity 0.2s;
            pointer-events: none;
            box-shadow: 0 4px 12px var(--shadow);
            z-index: 100;
            max-width: 200px;
            white-space: normal;
            text-align: center;
        }
        
        .footer {
            background: var(--bg-secondary);
            padding: 15px 20px;
            border-top: 2px solid var(--border-color);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-shrink: 0;
        }
        
        .selected-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .selected-emoji {
            font-size: 2em;
        }
        
        .selected-name {
            font-weight: 500;
        }
        
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            font-size: 1em;
            cursor: pointer;
            transition: all 0.2s;
            font-weight: 500;
        }
        
        .btn-primary {
            background: var(--accent-color);
            color: white;
        }
        
        .btn-primary:hover {
            background: var(--accent-hover);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px var(--shadow);
        }
        
        .btn-primary:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }
        
        .btn-secondary {
            background: var(--bg-hover);
            color: var(--text-primary);
        }
        
        .btn-secondary:hover {
            background: var(--border-color);
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: var(--text-secondary);
        }
        
        .empty-state-icon {
            font-size: 4em;
            margin-bottom: 20px;
        }
        
        .recent-emojis {
            padding: 10px 20px;
            border-bottom: 1px solid var(--border-color);
            background: var(--bg-secondary);
        }
        
        .recent-title {
            font-size: 0.9em;
            color: var(--text-secondary);
            margin-bottom: 10px;
        }
        
        .recent-grid {
            display: flex;
            gap: 8px;
            overflow-x: auto;
        }
        
        .recent-item {
            font-size: 2em;
            padding: 8px;
            background: var(--bg-primary);
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s;
            border: 2px solid transparent;
        }
        
        .recent-item:hover {
            border-color: var(--accent-color);
            transform: scale(1.1);
        }
        
        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            background: #10b981;
            color: white;
            padding: 15px 25px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.2);
            z-index: 1000;
            animation: slideIn 0.3s ease;
        }
        
        @keyframes slideIn {
            from {
                transform: translateX(400px);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        
        .keyboard-hint {
            font-size: 0.85em;
            color: var(--text-secondary);
            margin-top: 5px;
        }
        
        ::-webkit-scrollbar {
            width: 12px;
            height: 12px;
        }
        
        ::-webkit-scrollbar-track {
            background: var(--bg-secondary);
        }
        
        ::-webkit-scrollbar-thumb {
            background: var(--border-color);
            border-radius: 6px;
        }
        
        ::-webkit-scrollbar-thumb:hover {
            background: var(--text-secondary);
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🎭 Emoji Picker</h1>
        <div class="search-container">
            <input type="text" class="search-box" id="searchInput" placeholder="🔍 Search emojis by name or keyword..." autofocus>
        </div>
        <div class="stats">
            <span id="visibleCount">0</span> emojis
        </div>
    </div>
    
    <div id="recentContainer" class="recent-emojis" style="display: none;">
        <div class="recent-title">⭐ Recently Used</div>
        <div class="recent-grid" id="recentGrid"></div>
    </div>
    
    <div class="categories">
        <button class="category-btn active" data-category="" onclick="filterByCategory('')">All</button>
    </div>
    
    <div class="content">
        <div class="emoji-grid" id="emojiGrid"></div>
        <div class="empty-state" id="emptyState" style="display: none;">
            <div class="empty-state-icon">🔍</div>
            <h2>No emojis found</h2>
            <p>Try a different search term or category</p>
        </div>
    </div>
    
    <div class="footer">
        <div class="selected-info">
            <span class="selected-emoji" id="selectedEmoji">❓</span>
            <div>
                <div class="selected-name" id="selectedName">Select an emoji</div>
                <div class="keyboard-hint">Click to select • Double-click to copy & close • ESC to cancel</div>
            </div>
        </div>
        <div>
            <button class="btn btn-secondary" onclick="closeWindow()">Cancel</button>
            <button class="btn btn-primary" id="selectBtn" onclick="selectEmoji()" disabled>Select & Copy</button>
        </div>
    </div>
    
    <script>
        const emojis = $emojiJson;
        const categories = $categoriesJson;
        const collections = $collectionsJson;
        const serverPort = $Port;
        const standaloneMode = $($Standalone.IsPresent.ToString().ToLower());
        const initialCategory = $(if ($Category) { "'$Category'" } else { 'null' });
        const initialCollection = $(if ($Collection) { "'$Collection'" } else { 'null' });
        let selectedEmojiData = null;
        let filteredEmojis = emojis;
        let recentEmojis = JSON.parse(localStorage.getItem('emojiTools_recent') || '[]');
        
        // Debug logging
        console.log('Loaded emojis:', emojis.length);
        console.log('Loaded categories:', categories.length);
        console.log('Loaded collections:', Object.keys(collections).length);
        console.log('First emoji:', emojis[0]);
        console.log('Server port:', serverPort);
        console.log('Standalone mode:', standaloneMode);
        console.log('Initial category:', initialCategory);
        console.log('Initial collection:', initialCollection);
        
        // Search functionality
        document.getElementById('searchInput').addEventListener('input', (e) => {
            const query = e.target.value.toLowerCase();
            const activeCategory = document.querySelector('.category-btn.active')?.dataset.category;
            
            filteredEmojis = emojis.filter(emoji => {
                const matchesSearch = !query || 
                    emoji.name.toLowerCase().includes(query) || 
                    emoji.keywords.toLowerCase().includes(query);
                const matchesCategory = !activeCategory || emoji.category === activeCategory;
                return matchesSearch && matchesCategory;
            });
            
            renderEmojis(filteredEmojis);
        });
        
        function renderCategories() {
            const container = document.querySelector('.categories');
            const allBtn = container.querySelector('.category-btn');
            allBtn.dataset.category = '';  // Set empty category for "All"
            allBtn.dataset.type = 'category';
            
            // Add regular categories
            categories.forEach(cat => {
                const btn = document.createElement('button');
                btn.className = 'category-btn';
                btn.dataset.category = cat;
                btn.dataset.type = 'category';
                btn.textContent = cat;
                btn.onclick = () => filterByCategory(cat);
                container.appendChild(btn);
            });
            
            // Add separator if we have collections
            if (Object.keys(collections).length > 0) {
                const separator = document.createElement('div');
                separator.style.borderTop = '1px solid var(--border-color)';
                separator.style.margin = '8px 0';
                separator.style.width = '100%';
                container.appendChild(separator);
                
                const collectionLabel = document.createElement('div');
                collectionLabel.textContent = '📚 Collections';
                collectionLabel.style.fontSize = '11px';
                collectionLabel.style.color = 'var(--text-muted)';
                collectionLabel.style.padding = '4px 8px';
                collectionLabel.style.fontWeight = 'bold';
                container.appendChild(collectionLabel);
            }
            
            // Add collection buttons
            Object.keys(collections).sort().forEach(collName => {
                const btn = document.createElement('button');
                btn.className = 'category-btn';
                btn.dataset.collection = collName;
                btn.dataset.type = 'collection';
                btn.textContent = '📁 ' + collName;
                btn.onclick = () => filterByCollection(collName);
                container.appendChild(btn);
            });
        }
        
        function filterByCategory(category) {
            document.querySelectorAll('.category-btn').forEach(btn => {
                btn.classList.toggle('active', btn.dataset.category === category && btn.dataset.type === 'category');
            });
            
            const query = document.getElementById('searchInput').value.toLowerCase();
            
            filteredEmojis = emojis.filter(emoji => {
                const matchesSearch = !query || 
                    emoji.name.toLowerCase().includes(query) || 
                    emoji.keywords.toLowerCase().includes(query);
                const matchesCategory = !category || emoji.category === category;
                return matchesSearch && matchesCategory;
            });
            
            renderEmojis(filteredEmojis);
        }
        
        function filterByCollection(collectionName) {
            document.querySelectorAll('.category-btn').forEach(btn => {
                btn.classList.toggle('active', btn.dataset.collection === collectionName);
            });
            
            const query = document.getElementById('searchInput').value.toLowerCase();
            const collectionEmojis = collections[collectionName] || [];
            
            filteredEmojis = emojis.filter(emoji => {
                const matchesSearch = !query || 
                    emoji.name.toLowerCase().includes(query) || 
                    emoji.keywords.toLowerCase().includes(query);
                const inCollection = collectionEmojis.includes(emoji.emoji);
                return matchesSearch && inCollection;
            });
            
            renderEmojis(filteredEmojis);
        }
        
        // Initialize
        renderCategories();
        
        // Apply initial category or collection filter if specified
        if (initialCollection) {
            filterByCollection(initialCollection);
        } else if (initialCategory) {
            filterByCategory(initialCategory);
        } else {
            renderEmojis(emojis);
        }
        
        renderRecentEmojis();
        
        function renderEmojis(emojiList) {
            const grid = document.getElementById('emojiGrid');
            const emptyState = document.getElementById('emptyState');
            const visibleCount = document.getElementById('visibleCount');
            
            grid.innerHTML = '';
            visibleCount.textContent = emojiList.length;
            
            if (emojiList.length === 0) {
                grid.style.display = 'none';
                emptyState.style.display = 'block';
                return;
            }
            
            grid.style.display = 'grid';
            emptyState.style.display = 'none';
            
            emojiList.forEach(emoji => {
                const item = document.createElement('div');
                item.className = 'emoji-item';
                item.innerHTML = ``
                    <div class="emoji-symbol">`` + emoji.emoji + ``</div>
                    <div class="emoji-tooltip">`` + emoji.name + ``</div>
                ``;
                item.onclick = () => selectEmojiItem(emoji);
                item.ondblclick = () => {
                    selectEmojiItem(emoji);
                    selectEmoji();
                };
                grid.appendChild(item);
            });
        }
        
        function selectEmojiItem(emoji) {
            selectedEmojiData = emoji;
            document.getElementById('selectedEmoji').textContent = emoji.emoji;
            document.getElementById('selectedName').textContent = emoji.name;
            document.getElementById('selectBtn').disabled = false;
        }
        
        function selectEmoji() {
            if (!selectedEmojiData) return;
            
            // Add to recent
            addToRecent(selectedEmojiData);
            
            // Copy to clipboard
            const textarea = document.createElement('textarea');
            textarea.value = selectedEmojiData.emoji;
            document.body.appendChild(textarea);
            textarea.select();
            document.execCommand('copy');
            document.body.removeChild(textarea);
            
            // Show notification
            showNotification('Copied: ' + selectedEmojiData.emoji + ' ' + selectedEmojiData.name);
            
            // Send to PowerShell and close (only in server mode)
            if (!standaloneMode) {
                fetch('http://localhost:' + serverPort + '/select', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(selectedEmojiData)
                }).then(() => {
                    // Window will be closed by PowerShell
                }).catch(err => {
                    console.log('Could not notify server:', err);
                    showNotification('Copied! Close this window when done.');
                });
            } else {
                // Standalone mode - show message to close manually
                showNotification('Copied! You can close this window now.');
            }
        }
        
        function addToRecent(emoji) {
            // Remove if already exists
            recentEmojis = recentEmojis.filter(e => e.emoji !== emoji.emoji);
            // Add to front
            recentEmojis.unshift(emoji);
            // Keep only 10
            recentEmojis = recentEmojis.slice(0, 10);
            // Save
            localStorage.setItem('emojiTools_recent', JSON.stringify(recentEmojis));
            // Render
            renderRecentEmojis();
        }
        
        function renderRecentEmojis() {
            if (recentEmojis.length === 0) return;
            
            const container = document.getElementById('recentContainer');
            const grid = document.getElementById('recentGrid');
            
            container.style.display = 'block';
            grid.innerHTML = '';
            
            recentEmojis.forEach(emoji => {
                const item = document.createElement('div');
                item.className = 'recent-item';
                item.textContent = emoji.emoji;
                item.title = emoji.name;
                item.onclick = () => {
                    selectEmojiItem(emoji);
                    selectEmoji();
                };
                grid.appendChild(item);
            });
        }
        
        function closeWindow() {
            if (!standaloneMode) {
                fetch('http://localhost:' + serverPort + '/cancel', { method: 'POST' })
                    .then(() => {
                        // Window will be closed by PowerShell
                    })
                    .catch(err => {
                        console.log('Could not notify server:', err);
                        window.close();
                    });
            } else {
                window.close();
            }
        }
        
        function showNotification(message) {
            const notification = document.createElement('div');
            notification.className = 'notification';
            notification.textContent = message;
            document.body.appendChild(notification);
            setTimeout(() => notification.remove(), 2000);
        }
        
        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                closeWindow();
            } else if (e.key === 'Enter' && selectedEmojiData) {
                selectEmoji();
            }
        });
    </script>
</body>
</html>
"@

    # Save HTML to temp file
    $tempHtml = Join-Path $env:TEMP "emoji-picker-debug.html"
    $html | Out-File -FilePath $tempHtml -Encoding UTF8
    
    Write-Host "🎭 Opening emoji picker..." -ForegroundColor Cyan
    Write-Host "   HTML saved to: $tempHtml" -ForegroundColor Gray
    
    # Standalone mode - just open and exit
    if ($Standalone) {
        Write-Host "   Standalone mode: Close browser window manually when done" -ForegroundColor Yellow
        Start-Process $tempHtml
        Write-Host "✅ Emoji picker opened" -ForegroundColor Green
        return
    }
    
    Write-Host "   Tip: Double-click an emoji to select and close" -ForegroundColor Yellow
    
    # Start HTTP listener for receiving selection
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:$Port/")
    
    try {
        $listener.Start()
        Write-Host "   Listening on http://localhost:$Port" -ForegroundColor Gray
        
        # Open in browser and track the process
        $browserProcess = Start-Process $tempHtml -PassThru
        
        # Wait for selection
        $selectedEmoji = $null
        $timeout = New-TimeSpan -Minutes 10
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        
        Write-Host "   Waiting for selection..." -ForegroundColor Gray
        
        $contextTask = $null
        while ($stopwatch.Elapsed -lt $timeout) {
            if ($listener.IsListening) {
                # Create task only if we don't have one waiting
                if ($null -eq $contextTask -or $contextTask.IsCompleted) {
                    $contextTask = $listener.GetContextAsync()
                }
                
                # Wait briefly so we can respond to Ctrl+C
                if ($contextTask.Wait(200)) {
                    $context = $contextTask.Result
                    $request = $context.Request
                    $response = $context.Response
                    
                    Write-Verbose "Received request: $($request.HttpMethod) $($request.Url.AbsolutePath)"
                    
                    # Add CORS headers
                    $response.AddHeader("Access-Control-Allow-Origin", "*")
                    $response.AddHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
                    $response.AddHeader("Access-Control-Allow-Headers", "Content-Type")
                    
                    if ($request.HttpMethod -eq 'OPTIONS') {
                        # Handle preflight
                        $response.StatusCode = 200
                        $response.Close()
                        $contextTask = $null  # Reset to listen for next request
                        continue
                    }
                    
                    if ($request.Url.AbsolutePath -eq '/select' -and $request.HttpMethod -eq 'POST') {
                        $reader = New-Object System.IO.StreamReader($request.InputStream)
                        $body = $reader.ReadToEnd()
                        $reader.Close()
                        
                        $selectedEmoji = $body | ConvertFrom-Json
                        
                        $response.StatusCode = 200
                        $responseString = "OK"
                        $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseString)
                        $response.ContentLength64 = $buffer.Length
                        $response.OutputStream.Write($buffer, 0, $buffer.Length)
                        $response.Close()
                        break
                    }
                    elseif ($request.Url.AbsolutePath -eq '/cancel') {
                        $response.StatusCode = 200
                        $responseString = "OK"
                        $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseString)
                        $response.ContentLength64 = $buffer.Length
                        $response.OutputStream.Write($buffer, 0, $buffer.Length)
                        $response.Close()
                        Write-Host "❌ Cancelled" -ForegroundColor Yellow
                        break
                    }
                    else {
                        $response.StatusCode = 404
                        $response.Close()
                        $contextTask = $null  # Reset to listen for next request
                    }
                }
                # If no request in 200ms, loop continues and can check for Ctrl+C
            }
        }
        
        $stopwatch.Stop()
        
        # Close browser window
        if ($browserProcess -and -not $browserProcess.HasExited) {
            try {
                $browserProcess.CloseMainWindow() | Out-Null
                Start-Sleep -Milliseconds 500
                if (-not $browserProcess.HasExited) {
                    $browserProcess.Kill()
                }
            }
            catch {
                Write-Verbose "Could not close browser process: $_"
            }
        }
    }
    finally {
        $listener.Stop()
        $listener.Close()
        
        # Clean up temp file
        if (Test-Path $tempHtml) {
            Remove-Item $tempHtml -Force -ErrorAction SilentlyContinue
        }
    }
    
    if ($selectedEmoji) {
        Write-Host "✅ Selected: $($selectedEmoji.emoji) $($selectedEmoji.name)" -ForegroundColor Green
        
        if ($ReturnEmoji) {
            return $selectedEmoji.emoji
        }
        else {
            # Also copy to clipboard on PowerShell side (backup in case JS failed)
            try {
                Set-Clipboard -Value $selectedEmoji.emoji
                Write-Host "📋 Copied to clipboard!" -ForegroundColor Cyan
            }
            catch {
                Write-Host "📋 Emoji selected (clipboard copy handled by browser)" -ForegroundColor Cyan
            }
        }
    }
    elseif ($stopwatch.Elapsed -ge $timeout) {
        Write-Host "⏱️  Timed out waiting for selection" -ForegroundColor Yellow
    }
}

