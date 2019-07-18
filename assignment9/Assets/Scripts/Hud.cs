using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

// AS9.3 - HUD for camera that displays the level count

public class Hud : MonoBehaviour
{
    public static Text levelText;

    public static Color levelContrast;

    // Use this for initialization
    void Start()
    {
        // Finding the level count object on the canvas
        GameObject levelCount = GameObject.Find("Level Count");
        levelText = levelCount.GetComponent<Text>();

        // Creating level text
        levelText.text = "Lv. " + PlayerStats.level.ToString();

        // Creating contrasting color for text
        // Minimum sat and bright values to be able to read the text
        levelContrast = Color.HSVToRGB(
                            (SceneLightingRandomizer.hue + 0.5f) % 1,
                            Mathf.Max(SceneLightingRandomizer.saturation, 0.2f),
                            Mathf.Max(SceneLightingRandomizer.brightness, 0.5f));

        levelText.color = levelContrast;
    }

    // Update is called once per frame
    void Update()
    {

    }
}
