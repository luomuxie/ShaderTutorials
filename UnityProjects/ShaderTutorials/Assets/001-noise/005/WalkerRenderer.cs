using UnityEngine;

public class WalkerRenderer : MonoBehaviour
{
    public Material walkerMaterial;
    public RenderTexture walkerTextureA;
    public RenderTexture walkerTextureB;

    private RenderTexture currentSource;
    private RenderTexture currentDest;
    
    public SpriteRenderer sprite2dRenderer;
    private float timer = 0.0f;
    public float speed = 0.5f;

    void Start()
    {
        // Initialize the textures
        
        sprite2dRenderer = GetComponent<SpriteRenderer>();
        var spriteTexture = sprite2dRenderer.sprite.texture;
        walkerTextureA = new RenderTexture(spriteTexture.width, spriteTexture.height, 0);
        walkerTextureB = new RenderTexture(spriteTexture.width, spriteTexture.height, 0);
        


        currentSource = walkerTextureA;
        currentDest = walkerTextureB;
        // Initialize with the sprite texture
        Graphics.Blit(spriteTexture, currentSource);
        Graphics.Blit(spriteTexture, currentDest);
        
        // Initialize with any specific content if necessary
        Graphics.Blit(null, currentSource);
    }

    void Update()
    {
        // Set the speed of the walker
        timer+= Time.deltaTime;
        if(timer > speed)
        {
            timer = 0.0f;
            // Set the input texture for the material
            walkerMaterial.SetTexture("_InputTex", currentSource);

            // Perform the effect
            Graphics.Blit(currentSource, currentDest, walkerMaterial);

            // Swap textures
            Swap(ref currentSource, ref currentDest);
        }
    }

    private void Swap(ref RenderTexture source, ref RenderTexture dest)
    {
        RenderTexture temp = source;
        source = dest;
        dest = temp;
    }
    
    void OnDestroy()
    {
        // Release the resources
        walkerTextureA.Release();
        walkerTextureB.Release();
    }
}