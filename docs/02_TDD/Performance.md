# Performa & Profiling

## Ringkasan

Dokumen ini menjelaskan strategi optimasi performa dan tools profiling yang digunakan.

## Target Performa

| Platform | Target FPS | Min FPS |
|----------|-----------|---------|
| PC (High) | 60 FPS | 45 FPS |
| PC (Low) | 30 FPS | 24 FPS |
| Mobile | 30 FPS | 24 FPS |

## Profiling Tools

### Unity Profiler
- CPU usage
- GPU usage
- Memory allocation
- Rendering stats

### Frame Debugger
- Step through draw calls
- Identify overdraw
- Optimize batching

### Memory Profiler
- Memory snapshots
- Leak detection
- Asset analysis

## Optimasi Rendering

### 1. LOD (Level of Detail)
```csharp
public class LODController : MonoBehaviour
{
    [SerializeField] private LOD[] lods;
    
    void Update()
    {
        float distance = Vector3.Distance(
            transform.position, Camera.main.transform.position);
        
        for (int i = 0; i < lods.Length; i++)
        {
            if (distance >= lods[i].distance)
            {
                SetLOD(i);
                break;
            }
        }
    }
}
```

| LOD | Distance | Triangles |
|-----|----------|-----------|
| High | 0-20m | 100% |
| Medium | 20-50m | 50% |
| Low | 50-100m | 25% |
| Culled | 100m+ | 0% |

### 2. Occlusion Culling
- Hanya render objek yang terlihat kamera
- Unity built-in occlusion culling
- Bake saat build

### 3. Batching
- **Static Batching** — Objek statik di-batch
- **Dynamic Batching** — Objek dinamik kecil
- **GPU Instancing** — Objek identik

### 4. Texture Optimization
| Setting | Value |
|---------|-------|
| Max Size | 2048 (mobile: 1024) |
| Format | ASTC (mobile), DXT (PC) |
| Mipmap | Enabled |
| Compression | High Quality |

## Optimasi Script

### 1. Object Pooling
```csharp
// Instead of Instantiate/Destroy
var bullet = pool.Get();
// ... use bullet ...
pool.Return(bullet);
```

### 2. Caching
```csharp
// Cache component references
private Rigidbody rb;
void Awake() => rb = GetComponent<Rigidbody>();
```

### 3. Avoid Alloc in Update
```csharp
// Bad
void Update()
{
    var enemies = FindObjectsOfType<Enemy>(); // Alloc!
}

// Good
private Enemy[] enemies;
void Start() => enemies = FindObjectsOfType<Enemy>();
```

## Optimasi Audio

| Setting | Value |
|---------|-------|
| Format | Vorbis (OGG) |
| Compression | 50% |
| Load Type | Compressed In Memory |
| Streaming | BGM only |

## Memory Budget

| Category | Budget |
|----------|--------|
| Textures | 256 MB |
| Meshes | 128 MB |
| Audio | 64 MB |
| Scripts | 32 MB |
| Other | 20 MB |
| **Total** | **500 MB** |
