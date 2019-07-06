// AS8 - GemSpawner very similar to CoinSpawner

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GemSpawner : MonoBehaviour
{
    public GameObject[] prefabs;

    // Use this for initialization
    void Start()
    {
        StartCoroutine(SpawnGems());
    }

    // Update is called once per frame
    void Update()
    {

    }

    IEnumerator SpawnGems()
    {
        while (true)
        {
            int gemsThisRow = Random.Range(1, 3);

            for (int i = 0; i < gemsThisRow; i++)
            {
                Instantiate(prefabs[Random.Range(0, prefabs.Length)],
                    new Vector3(26, Random.Range(-10, 10), 10),
                    Quaternion.identity);
            }

            // pausing for longer to make gems rarer than coins.
            // Coins pause 1-5
            yield return new WaitForSeconds(Random.Range(5, 10));
        }
    }
}
