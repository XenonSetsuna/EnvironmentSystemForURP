using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TimeSet : MonoBehaviour
{
    public Material SkyboxMaterial;
    public GameObject DirectionalLight;
    public GameObject Sun;
    public GameObject Moon;
    public GameObject CenterPoint;
    public float Time = 6.0f;
    public float TimeSetSpeed = 1.0f;
    public float SunLightIntensity = 1.5f;
    public float MoonLightIntensity = 0.5f;
    public Vector3 RotationAxis = new Vector3(1.0f, 0.0f, 0.0f);

    public Color SunRiseColor = new Color(1.0f, 0.75f, 0.5f);
    public Color DayColor = new Color(1.0f, 0.95f, 0.9f);
    public Color MoonRiseColor = new Color(0.5f, 0.5f, 0.5f);
    public Color NightColor = new Color(0.6f, 0.8f, 1.0f);

    private float Distance = 0.5f;
    private Vector3 SunPosition;
    private Vector3 MoonPosition;
    private float SunAngleH1 = 0.0f;
    private float SunAngleH2 = 0.0f;


    void Update()
    {
        doRotation();
        doLightSwitch();
        setTime();
    }

    float smoothstep(float t1, float t2, float x)//把Shader里常用的smoothstep函数搬到了C#
    {
        x = Mathf.Clamp((x - t1) / (t2 - t1), 0.0f, 1.0f);
        return x * x * (3 - 2 * x);
    }
    void setTime()//将时间变量的数值映射到太阳光角度变量数值上
    {
        if (Time >= 24.0f)
        {
            Time = 0.0f;
        }
        SunAngleH1 = (Time - 6.0f) * 15.0f;
        Time += 0.001f * TimeSetSpeed;
        if (Time >= 0.0f && Time < 12.0f)
        {
            SkyboxMaterial.SetFloat("_TimeMapping", (Time - 6.0f) / 6.0f);
        }
        else if (Time >= 12.0f && Time < 24.0f)
        {
            SkyboxMaterial.SetFloat("_TimeMapping", (18.0f - Time) / 6.0f);
        }
    }
    void doRotation()//中心物体绕向量旋转，太阳与月亮平行光始终看向中心物体且分别位于中心物体前后两侧
    {
        CenterPoint.transform.rotation *= Quaternion.AngleAxis(SunAngleH1 - SunAngleH2, RotationAxis);
        SunAngleH2 = SunAngleH1;
        SunPosition = CenterPoint.transform.position + Vector3.Normalize(-CenterPoint.transform.forward) * Distance;
        MoonPosition = CenterPoint.transform.position + Vector3.Normalize(CenterPoint.transform.forward) * Distance;
        Sun.transform.position = SunPosition;
        Moon.transform.position = MoonPosition;
        Sun.transform.LookAt(CenterPoint.transform);
        Moon.transform.LookAt(CenterPoint.transform);
        /**if (Time >= 6.0f && Time < 18.0f)
        {
            DirectionalLight.transform.position = SunPosition;
        }
        else
        {
            DirectionalLight.transform.position = MoonPosition;
        }
        DirectionalLight.transform.LookAt(CenterPoint.transform);**/
    }
    void doLightSwitch()//控制太阳与月亮平行光的参数变化
    {
        if (Time >= 6.0f && Time < 18.0f)
        {
            Sun.SetActive(true);
            Moon.SetActive(false);

            Sun.transform.GetComponent<Light>().intensity = 0.01f + SunLightIntensity * smoothstep(0.0f, 0.4f, System.Math.Max(Vector3.Dot(Vector3.Normalize(Sun.transform.forward), new Vector3(0.0f, -1.0f, 0.0f)), 0.0f));
            Sun.transform.GetComponent<Light>().color = Color.Lerp(new Color(1.0f, 0.75f, 0.5f), new Color(1.0f, 0.95f, 0.9f), smoothstep(0.0f, 0.6f, (float)System.Math.Pow(Vector3.Dot(Vector3.Normalize(Sun.transform.forward), new Vector3(0.0f, -1.0f, 0.0f)), 1.5f)));
            Sun.transform.GetComponent<Light>().shadowStrength = Sun.transform.GetComponent<Light>().intensity / SunLightIntensity / 1.5f;
            //DirectionalLight.transform.GetComponent<Light>().intensity = SunLightIntensity * smoothstep(0.0f, 0.4f, System.Math.Max(Vector3.Dot(Vector3.Normalize(DirectionalLight.transform.forward), new Vector3(0.0f, -1.0f, 0.0f)), 0.0f));
            //DirectionalLight.transform.GetComponent<Light>().color = Color.Lerp(new Color(1.0f, 0.75f, 0.5f), new Color(1.0f, 0.95f, 0.9f), smoothstep(0.0f, 0.6f, (float)System.Math.Pow(Vector3.Dot(Vector3.Normalize(DirectionalLight.transform.forward), new Vector3(0.0f, -1.0f, 0.0f)), 1.5f)));
            //DirectionalLight.transform.GetComponent<Light>().shadowStrength = DirectionalLight.transform.GetComponent<Light>().intensity / SunLightIntensity / 1.25f;
        }
        else
        {           
            Moon.SetActive(true);
            Sun.SetActive(false);

            Moon.transform.GetComponent<Light>().intensity = 0.01f + MoonLightIntensity * smoothstep(0.0f, 0.3f, System.Math.Max(Vector3.Dot(Vector3.Normalize(Moon.transform.forward), new Vector3(0.0f, -1.0f, 0.0f)), 0.0f));
            Moon.transform.GetComponent<Light>().color = Color.Lerp(new Color(0.5f, 0.5f, 0.5f), new Color(0.6f, 0.8f, 1.0f), smoothstep(0.0f, 0.6f, System.Math.Max(Vector3.Dot(Vector3.Normalize(Moon.transform.forward), new Vector3(0.0f, -1.0f, 0.0f)), 0.0f)));
            Moon.transform.GetComponent<Light>().shadowStrength = Moon.transform.GetComponent<Light>().intensity / MoonLightIntensity / 2.0f;
            //DirectionalLight.transform.GetComponent<Light>().intensity = MoonLightIntensity * smoothstep(0.0f, 0.3f, System.Math.Max(Vector3.Dot(Vector3.Normalize(DirectionalLight.transform.forward), new Vector3(0.0f, -1.0f, 0.0f)), 0.0f));
            //DirectionalLight.transform.GetComponent<Light>().color = Color.Lerp(new Color(0.5f, 0.5f, 0.5f), new Color(0.6f, 0.8f, 1.0f), smoothstep(0.0f, 0.6f, System.Math.Max(Vector3.Dot(Vector3.Normalize(DirectionalLight.transform.forward), new Vector3(0.0f, -1.0f, 0.0f)), 0.0f)));
            //DirectionalLight.transform.GetComponent<Light>().shadowStrength = DirectionalLight.transform.GetComponent<Light>().intensity / MoonLightIntensity / 1.5f;
        }
    }
}