using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SceneLightingRandomizer : MonoBehaviour
{

    public static float red;

    public static float green;

    public static float blue;

    // Use this for initialization
    void Start()
    {
        red = Random.value;
        green = Random.value;
        blue = Random.value;

        RenderSettings.ambientLight = new Color(red, green, blue);
        //RenderSettings.ambientIntensity = 1.0f;
        RenderSettings.fogColor = new Color(red - 0.15f, green - 0.15f, blue - 0.15f);

    }

    // Update is called once per frame
    void Update()
    {

    }
}
