# Sistem Kamera

## Ringkasan

Sistem kamera mengikuti pemain dengan berbagai mode dan fitur.

## Camera Modes

### 1. Third Person Follow
- Kamera di belakang pemain
- Mengikuti pemain secara smooth
- Default mode

### 2. Lock-On Camera
- Kamera fokus ke target
- Saat Target Lock aktif
- Mengikuti target bergerak

### 3. Free Camera
- Kamera bisa dirotasi bebas
- Saat eksplorasi
- Mouse/right stick untuk rotasi

### 4. Cutscene Camera
- Kamera bergerak sesuai skrip
- Saat cutscene
- Pre-defined path

## Camera Controller

```csharp
public class CameraController : MonoBehaviour
{
    [SerializeField] private Transform target;
    [SerializeField] private float distance = 5f;
    [SerializeField] private float height = 2f;
    [SerializeField] private float smoothSpeed = 5f;
    [SerializeField] private float rotationSpeed = 3f;
    
    private float yaw;
    private float pitch;
    
    void LateUpdate()
    {
        // Input rotasi
        yaw += Input.GetAxis("Mouse X") * rotationSpeed;
        pitch -= Input.GetAxis("Mouse Y") * rotationSpeed;
        pitch = Mathf.Clamp(pitch, -30f, 60f);
        
        // Hitung posisi
        Quaternion rotation = Quaternion.Euler(pitch, yaw, 0);
        Vector3 offset = rotation * new Vector3(0, height, -distance);
        Vector3 targetPosition = target.position + offset;
        
        // Smooth follow
        transform.position = Vector3.Lerp(
            transform.position, targetPosition, smoothSpeed * Time.deltaTime);
        transform.LookAt(target);
    }
}
```

## Camera Collision

```csharp
public class CameraCollision : MonoBehaviour
{
    [SerializeField] private float minDistance = 1f;
    [SerializeField] private float maxDistance = 5f;
    [SerializeField] private LayerMask collisionLayer;
    
    public float GetAdjustedDistance()
    {
        RaycastHit hit;
        if (Physics.Raycast(target.position, -transform.forward, 
            out hit, maxDistance, collisionLayer))
        {
            return Mathf.Clamp(hit.distance, minDistance, maxDistance);
        }
        return maxDistance;
    }
}
```

## Camera Shake

```csharp
public class CameraShake : MonoBehaviour
{
    public void Shake(float intensity, float duration)
    {
        StartCoroutine(ShakeCoroutine(intensity, duration));
    }
    
    private IEnumerator ShakeCoroutine(float intensity, float duration)
    {
        float elapsed = 0f;
        while (elapsed < duration)
        {
            float x = Random.Range(-1f, 1f) * intensity;
            float y = Random.Range(-1f, 1f) * intensity;
            transform.localPosition += new Vector3(x, y, 0);
            elapsed += Time.deltaTime;
            yield return null;
        }
    }
}
```

## Camera Settings

| Setting | Range | Default |
|---------|-------|---------|
| FOV | 40-90 | 60 |
| Distance | 2-10 | 5 |
| Height | 0-5 | 2 |
| Sensitivity | 0.1-5.0 | 1.0 |
| Smooth | 0.1-10 | 5 |
