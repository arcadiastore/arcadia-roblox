# Sistem Addressables

## Ringkasan

Unity Addressables digunakan untuk manajemen asset yang efisien, mendukung dynamic loading dan content update.

## Penggunaan Addressables

### Kategori Asset

| Kategori | Addressable Group | Load Type |
|----------|-------------------|-----------|
| Scenes | Scene Group | Async |
| Prefabs | Prefab Group | Async |
| Audio | Audio Group | Async |
| Textures | Texture Group | Async |
| Data | Data Group | Sync |

### Addressable Groups

```
Groups/
├── Default Local Group
│   ├── Scenes (semua scene)
│   └── Core prefabs
├── Audio Group
│   ├── BGM
│   └── SFX
├── Character Group
│   ├── Player prefabs
│   ├── NPC prefabs
│   └── Monster prefabs
├── Environment Group
│   ├── Terrain chunks
│   ├── Buildings
│   └── Props
└── UI Group
    ├── UI prefabs
    └── Sprites
```

## Loading Manager

```csharp
public class AssetManager : MonoBehaviour
{
    public static AssetManager Instance { get; private set; }
    
    public async Task<T> LoadAssetAsync<T>(string address) where T : Object
    {
        var handle = Addressables.LoadAssetAsync<T>(address);
        await handle.Task;
        
        if (handle.Status == AsyncOperationStatus.Succeeded)
            return handle.Result;
        
        Debug.LogError($"Failed to load asset: {address}");
        return null;
    }
    
    public void ReleaseAsset<T>(T asset)
    {
        Addressables.Release(asset);
    }
    
    public async Task LoadSceneAsync(string sceneName)
    {
        await Addressables.LoadSceneAsync(sceneName).Task;
    }
}
```

## Asset Labels

| Label | Fungsi |
|-------|--------|
| `always-loaded` | Selalu di memori |
| `preload` | Load saat game start |
| `on-demand` | Load saat dibutuhkan |
| `scene` | Scene asset |

## Content Update

### Strategy
1. **Static Content** — Tidak berubah (core assets)
2. **Dynamic Content** | Bisa di-update (new content)
3. **Remote Content** — Download dari server (MMORPG)

### Content Update Flow
```
1. Build initial content
2. Release game
3. Create new content
4. Build content update
5. Upload to CDN
6. Client downloads update
```

## Memory Management

```csharp
public class MemoryManager : MonoBehaviour
{
    private Dictionary<string, Object> cache = new Dictionary<string, Object>();
    [SerializeField] private long maxCacheSize = 512 * 1024 * 1024; // 512MB
    
    public void CheckMemoryUsage()
    {
        if (GetTotalCacheSize() > maxCacheSize)
        {
            UnloadLeastUsedAssets();
        }
    }
}
```

## Build Settings

| Setting | Value |
|---------|-------|
| Build Target | Android, iOS, PC |
| Compression | LZ4 |
| Include Addressables | Yes |
| Content Update | Enabled |
