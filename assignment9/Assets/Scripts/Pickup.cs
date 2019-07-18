using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pickup : MonoBehaviour
{

    // AS9.X - Audio tail plays at end of loop to have
    // a natural reverb and seamless loop
    public AudioSource audioLoop;
    public AudioSource audioTail;

    // Use this for initialization
    void Start()
    {
        audioLoop = GetComponent<AudioSource>();
        audioLoop.loop = true;
        audioLoop.playOnAwake = false;
        audioLoop.mute = false;

        // AS9.X - needed child to play simultaneous sound
        GameObject tailSource = this.transform.Find("TailSound").gameObject;
        audioTail = tailSource.GetComponent<AudioSource>();
        audioTail.loop = false;
        audioTail.playOnAwake = false;


        StartCoroutine(loopAudio());
    }

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(0, 5f, 0, Space.World);
    }

    IEnumerator loopAudio()
    {
        audioLoop.Play();
        // AS9.X - At the end of each audio loop source, tail will play
        while (true)
        {
            yield return new WaitForSeconds(audioLoop.clip.length);
            audioTail.PlayOneShot(audioTail.clip, 0.5f);
        }
    }
}
