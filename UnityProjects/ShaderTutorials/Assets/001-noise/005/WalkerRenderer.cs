using UnityEngine;

public class WalkerRenderer : MonoBehaviour
{
    public Material walkerMaterial;

    public RenderTexture currentSource;
    public RenderTexture currentDest;
    
    
    public Texture spriteTexture;
    public Texture spriteTextureBg;
    private float timer = 0.0f;
    public float speed = 0.5f;

    void Start()
    {
        // Initialize the textures
        
        
        // Initialize with the sprite texture
        // Graphics.Blit(spriteTexture, currentSource);
        // Graphics.Blit(spriteTextureBg, currentDest);
        
        Graphics.Blit(spriteTexture,  currentDest);
        Graphics.Blit(spriteTexture, currentSource);
        
        // Initialize with any specific content if necessary
        Graphics.Blit(null, currentSource);
    }

    void Update()
    {
        // Set the speed of the walker
        timer+= Time.deltaTime;
        if(timer > speed||true)
        {
            timer = 0.0f;
            // Set the input texture for the material
            walkerMaterial.SetTexture("_InputTex", currentSource);
            //set the input random val for v2
            Vector2 randInput = new Vector2(Random.value, Random.value);
            walkerMaterial.SetVector("_RandInput", randInput);
            

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
        //walkerTextureA.Release();
        //walkerTextureB.Release();
    }
}