# Optimasi Lanjutan

## Ringkasan

Dokumen ini membahas teknik optimasi lanjutan untuk menjaga performa game tetap stabil.

## Spatial Partitioning

### Quadtree (2D)
```csharp
public class Quadtree
{
    private Rectangle bounds;
    private List<Point> points;
    private Quadtree[] children;
    private int capacity = 4;
    
    public void Insert(Point point)
    {
        if (!bounds.Contains(point)) return;
        
        if (points.Count < capacity)
        {
            points.Add(point);
        }
        else
        {
            if (children[0] == null) Subdivide();
            foreach (var child in children)
                child.Insert(point);
        }
    }
    
    public List<Point> Query(Rectangle range)
    {
        // Return points within range
    }
}
```

### Octree (3D)
- Untuk deteksi collision 3D
- Membagi ruang menjadi 8 bagian
- Efisien untuk banyak objek

## Object Pool Advanced

```csharp
public class AdvancedPool<T> where T : MonoBehaviour
{
    private Stack<T> inactive = new Stack<T>();
    private HashSet<T> active = new HashSet<T>();
    private T prefab;
    private Transform parent;
    
    public T Get()
    {
        T obj = inactive.Count > 0 ? inactive.Pop() : CreateNew();
        obj.gameObject.SetActive(true);
        active.Add(obj);
        return obj;
    }
    
    public void Return(T obj)
    {
        obj.gameObject.SetActive(false);
        active.Remove(obj);
        inactive.Push(obj);
    }
    
    public void Prewarm(int count)
    {
        for (int i = 0; i < count; i++)
        {
            T obj = CreateNew();
            obj.gameObject.SetActive(false);
            inactive.Push(obj);
        }
    }
    
    public void ReturnAll()
    {
        foreach (var obj in active.ToList())
            Return(obj);
    }
}
```

## Async Operations

```csharp
public class AsyncLoader : MonoBehaviour
{
    public async Task LoadSceneAsync(string sceneName, 
        IProgress<float> progress = null)
    {
        var operation = SceneManager.LoadSceneAsync(sceneName);
        operation.allowSceneActivation = false;
        
        while (!operation.isDone)
        {
            progress?.Report(operation.progress);
            
            if (operation.progress >= 0.9f)
            {
                // Scene ready, wait for user input
                operation.allowSceneActivation = true;
            }
            
            await Task.Yield();
        }
    }
}
```

## Thread Safety

```csharp
public class ThreadSafeQueue<T>
{
    private readonly Queue<T> queue = new Queue<T>();
    private readonly object lockObj = new object();
    
    public void Enqueue(T item)
    {
        lock (lockObj) queue.Enqueue(item);
    }
    
    public T Dequeue()
    {
        lock (lockObj) return queue.Count > 0 ? queue.Dequeue() : default;
    }
}
```

## Garbage Collection

### Tips Minimasi GC
1. Hindari alloc di Update
2. Gunakan object pool
3. Gunakan struct untuk data kecil
4. Hindari string concatenation (gunakan StringBuilder)
5. Gunakan `NonAlloc` physics functions

```csharp
// Bad
void Update()
{
    string text = "HP: " + hp.ToString(); // Alloc!
}

// Good
private StringBuilder sb = new StringBuilder();
void Update()
{
    sb.Clear();
    sb.Append("HP: ");
    sb.Append(hp);
    string text = sb.ToString();
}
```

## Shader Optimization

| Technique | Fungsi |
|-----------|--------|
| Shader LOD | Hanya gunakan shader sesuai jarak |
| Instancing | Render banyak objek serupa |
| Batching | Gabung draw calls |
| Atlasing | Gabung texture kecil |

## Network Optimization (MMORPG)

| Technique | Fungsi |
|-----------|--------|
| Delta Compression | Kirim perubahan saja |
| Interest Management | Kirim data yang relevan |
| Prediction | Client prediction untuk smooth |
| Interpolation | Smooth antara update server |
