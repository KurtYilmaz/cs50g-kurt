using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// AS9.X - Random lighting for each scene

public class SceneLightingRandomizer : MonoBehaviour
{

    // RGB together are ambient light color
    // hue, saturation, lightness together are same color in HSV
    public static float red;

    public static float green;

    public static float blue;

    public static float hue;

    public static float saturation;

    public static float brightness;

    // Use this for initialization
    void Start()
    {
        // Randomized colors during start of scene
        red = Random.value;
        green = Random.value;
        blue = Random.value;

        // Color of the ambient lighting
        RenderSettings.ambientLight = new Color(red, green, blue);

        // Creating HSV to use for contrast calcualtions
        Color.RGBToHSV(RenderSettings.ambientLight, out hue, out saturation, out brightness);

        // Color of fog
        RenderSettings.fogColor = new Color(red - 0.15f, green - 0.15f, blue - 0.15f);

    }

    // Update is called once per frame
    void Update()
    {

    }
}
