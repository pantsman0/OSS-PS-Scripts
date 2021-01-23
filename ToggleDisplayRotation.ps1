Param ([Parameter(ParameterSetName="list")][switch]$listDisplays, [Parameter(ParameterSetName="change")][String]$displayName, [Parameter(ParameterSetName="change")][ValidateSet('DMO90','DMO180','DMO270')][String]$toggleOrientation="DMO270", [Parameter(ParameterSetName="change")][switch]$alignRight=$false, [Parameter(ParameterSetName="change")][switch]$preserveTop=$false)

$pinvokeCode = @" 
using System; 
using System.Runtime.InteropServices; 
using System.Collections.Generic;

namespace Resolution 
{ 
    [StructLayout(LayoutKind.Sequential)] 
    public struct DEVMODE1 
    { 
        [MarshalAs(UnmanagedType.ByValTStr,SizeConst=32)]
        public string dmDeviceName;
        public short  dmSpecVersion;
        public short  dmDriverVersion;
        public short  dmSize;
        public short  dmDriverExtra;
        public int    dmFields;
        public int    dmPositionX;
        public int    dmPositionY;
        public int    dmDisplayOrientation;
        public int    dmDisplayFixedOutput;
        public short  dmColor;
        public short  dmDuplex;
        public short  dmYResolution;
        public short  dmTTOption;
        public short  dmCollate;
        [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
        public string dmFormName;
        public short  dmLogPixels;
        public short  dmBitsPerPel;
        public int    dmPelsWidth;
        public int    dmPelsHeight;
        public int    dmDisplayFlags;
        public int    dmDisplayFrequency;
        public int    dmICMMethod;
        public int    dmICMIntent;
        public int    dmMediaType;
        public int    dmDitherType;
        public int    dmReserved1;
        public int    dmReserved2;
        public int    dmPanningWidth;
        public int    dmPanningHeight;
    }; 
	
	[Flags()]
	public enum DisplayDeviceStateFlags : int
	{
		/// <summary>The device is part of the desktop.</summary>
		AttachedToDesktop = 0x1,
		MultiDriver = 0x2,
		/// <summary>The device is part of the desktop.</summary>
		PrimaryDevice = 0x4,
		/// <summary>Represents a pseudo device used to mirror application drawing for remoting or other purposes.</summary>
		MirroringDriver = 0x8,
		/// <summary>The device is VGA compatible.</summary>
		VGACompatible = 0x10,
		/// <summary>The device is removable; it cannot be the primary display.</summary>
		Removable = 0x20,
		/// <summary>The device has more display modes than its output devices support.</summary>
		ModesPruned = 0x8000000,
		Remote = 0x4000000,
		Disconnect = 0x2000000
	}
	[StructLayout(LayoutKind.Sequential, CharSet=CharSet.Ansi)]
	public struct DISPLAY_DEVICE 
	{
		  [MarshalAs(UnmanagedType.U4)]
		  public int cb;
		  [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)]
		  public string DeviceName;
		  [MarshalAs(UnmanagedType.ByValTStr, SizeConst=128)]
		  public string DeviceString;
		  [MarshalAs(UnmanagedType.U4)]
		  public DisplayDeviceStateFlags StateFlags;
		  [MarshalAs(UnmanagedType.ByValTStr, SizeConst=128)]
		  public string DeviceID;
		[MarshalAs(UnmanagedType.ByValTStr, SizeConst=128)]
		  public string DeviceKey;
	}
    class User_32 
    { 
        [DllImport("user32.dll")] 
        public static extern int EnumDisplaySettings(string deviceName, int modeNum, ref DEVMODE1 devMode); 
        [DllImport("user32.dll")] 
        public static extern int ChangeDisplaySettingsEx(string deviceName, ref DEVMODE1 devMode, int hwnd, int flags, int lParam); 
		[DllImport("user32.dll")]
		public static extern bool EnumDisplayDevices(string lpDevice, uint iDevNum, ref DISPLAY_DEVICE lpDisplayDevice, uint dwFlags);
        public const int ENUM_CURRENT_SETTINGS = -1; 
        public const int CDS_UPDATEREGISTRY = 0x01; 
        public const int CDS_TEST = 0x02; 
        public const int DISP_CHANGE_SUCCESSFUL = 0; 
        public const int DISP_CHANGE_RESTART = 1; 
        public const int DISP_CHANGE_FAILED = -1; 
        public const int DMDO_DEFAULT = 0;
        public const int DMDO_90 = 1;
        public const int DMDO_180 = 2;
        public const int DMDO_270 = 3;
    } 
    public class Displays
    {
		public static IList<string> GetDisplayNames()
		{
			var returnVals = new List<string>();
			for(var x=0U; x<1024; ++x)
			{
				DISPLAY_DEVICE outVar = new DISPLAY_DEVICE();
				outVar.cb = (short)Marshal.SizeOf(outVar);
				if(User_32.EnumDisplayDevices(null, x, ref outVar, 1U))
				{
					returnVals.Add(outVar.DeviceName);
				}
			}
			return returnVals;
		}
		
		public static string GetCurrentResolution(string deviceName)
        {
            string returnValue = null;
            DEVMODE1 dm = GetDevMode1();
            if (0 != User_32.EnumDisplaySettings(deviceName, User_32.ENUM_CURRENT_SETTINGS, ref dm))
            {
                returnValue = "\"" + deviceName + "\" resolution: " + dm.dmPelsWidth + "," + dm.dmPelsHeight;
            }
            return returnValue;
        }

        public static IList<string> GetResolutions()
		{
			var displays = GetDisplayNames();
			var returnValue = new List<string>();
			foreach(var display in displays)
			{
				returnValue.Add(GetCurrentResolution(display));
			}
			return returnValue;
		}

        public static string GetCurrentProperties(string deviceName)
        {
            string returnValue = null;
            DEVMODE1 dm = GetDevMode1();
            if (0 != User_32.EnumDisplaySettings(deviceName, User_32.ENUM_CURRENT_SETTINGS, ref dm))
            {
                returnValue = "\"" +dm.dmDeviceName + "\" properties: "
                                + "DEVMODE1 {"
                                + "\tdmDeviceName: " + dm.dmDeviceName.ToString() +",\r\n"
                                + "\tdmSpecVersion: " + dm.dmSpecVersion.ToString() +",\r\n"
                                + "\tdmDriverVersion: " + dm.dmDriverVersion.ToString() +",\r\n"
                                + "\tdmSize: " + dm.dmSize.ToString() +",\r\n"
                                + "\tdmDriverExtra: " + dm.dmDriverExtra.ToString() +",\r\n"
                                + "\tdmFields: " + dm.dmFields.ToString() +",\r\n"
                                + "\tdmPositionX: " + dm.dmPositionX.ToString() +",\r\n"
                                + "\tdmPositionY: " + dm.dmPositionY.ToString() +",\r\n"
                                + "\tdmDisplayOrientation: " + dm.dmDisplayOrientation.ToString() +",\r\n"
                                + "\tdmDisplayFixedOutput: " + dm.dmDisplayFixedOutput.ToString() +",\r\n"
                                + "\tdmColor: " + dm.dmColor.ToString() +",\r\n"
                                + "\tdmDuplex: " + dm.dmDuplex.ToString() +",\r\n"
                                + "\tdmYResolution: " + dm.dmYResolution.ToString() +",\r\n"
                                + "\tdmTTOption: " + dm.dmTTOption.ToString() +",\r\n"
                                + "\tdmCollate: " + dm.dmCollate.ToString() +",\r\n"
                                + "\tdmFormName: " + dm.dmFormName.ToString() +",\r\n"
                                + "\tdmLogPixels: " + dm.dmLogPixels.ToString() +",\r\n"
                                + "\tdmBitsPerPel: " + dm.dmBitsPerPel.ToString() +",\r\n"
                                + "\tdmPelsWidth: " + dm.dmPelsWidth.ToString() +",\r\n"
                                + "\tdmPelsHeight: " + dm.dmPelsHeight.ToString() +",\r\n"
                                + "\tdmDisplayFlags: " + dm.dmDisplayFlags.ToString() +",\r\n"
                                + "\tdmDisplayFrequency: " + dm.dmDisplayFrequency.ToString() +",\r\n"
                                + "\tdmICMMethod: " + dm.dmICMMethod.ToString() +",\r\n"
                                + "\tdmICMIntent: " + dm.dmICMIntent.ToString() +",\r\n"
                                + "\tdmMediaType: " + dm.dmMediaType.ToString() +",\r\n"
                                + "\tdmDitherType: " + dm.dmDitherType.ToString() +",\r\n"
                                + "\tdmReserved1: " + dm.dmReserved1.ToString() +",\r\n"
                                + "\tdmReserved2: " + dm.dmReserved2.ToString() +",\r\n"
                                + "\tdmPanningWidth: " + dm.dmPanningWidth.ToString() +",\r\n"
                                + "\tdmPanningHeight: " + dm.dmPanningHeight.ToString() +",\r\n"
                                + "}";
            }
            return returnValue;
        }
		
		public static IList<string> GetProperties()
		{
			var displays = GetDisplayNames();
			var returnValue = new List<string>();
			foreach(var display in displays)
			{
				returnValue.Add(GetCurrentProperties(display));
			}
			return returnValue;
		}

        public static string GetCurrentPosition(string deviceName)
        {
            string returnValue = null;
            DEVMODE1 dm = GetDevMode1();
            if (0 != User_32.EnumDisplaySettings(deviceName, User_32.ENUM_CURRENT_SETTINGS, ref dm))
            {
                returnValue = "\"" +dm.dmDeviceName + "\" position: " + dm.dmPositionX + "," + dm.dmPositionY;
            }
            return returnValue;
        }
		
		public static IList<string> GetPositions()
		{
			var displays = GetDisplayNames();
			var returnValue = new List<string>();
			foreach(var display in displays)
			{
				returnValue.Add(GetCurrentPosition(display));
			}
			return returnValue;
		}

        public static int RotateDisplay(string deviceName, int toggleRotation, bool alignRight, bool alignTop){
            DEVMODE1 dm = GetDevMode1();
            if (0 == User_32.EnumDisplaySettings(deviceName, User_32.ENUM_CURRENT_SETTINGS, ref dm))
            {
                return 1;
            }

            // The following translation and rotation logic only applies for 90 degree turns (clockwise or anti-clockwise)
            // 90 degree turns occur when either
            //   A) the display is currently rotated 90 degresss; or
            //   B) the display is in the default rotation and a 90 degree rotation is requested
            // if the display orientation is not the default, it will always return to the default

            if ( (dm.dmDisplayOrientation % 2 == 1 ) || (dm.dmDisplayOrientation == User_32.DMDO_DEFAULT && toggleRotation % 2 == 1) ) {


                // If alignTop is false, we need to adjust the Y coordinate so that the center of the display remains at the same height.
                if (!alignTop) {
                    //update top level so screen center level remains the same.
                    int center_level  = dm.dmPositionY + (dm.dmPelsHeight / 2);
                    dm.dmPositionY = center_level - (dm.dmPelsWidth / 2);
                }


                // If the rotating display is on the left of the primary monitor, we need to move the X coordinate
                // of the display so that the display is still touching the primary monitor.
                if (alignRight) {
                    dm.dmPositionX += (dm.dmPelsWidth - dm.dmPelsHeight);
                }


                // swap width and height
                int temp = dm.dmPelsHeight;
                dm.dmPelsHeight = dm.dmPelsWidth;
                dm.dmPelsWidth = temp;
            }

            // determine new orientation based on the current orientation
            switch(dm.dmDisplayOrientation)
            {
               case User_32.DMDO_DEFAULT:
                    dm.dmDisplayOrientation = toggleRotation;
                    break;
                default:
                    dm.dmDisplayOrientation = User_32.DMDO_DEFAULT;
                    break;
            }


            int iRet = User_32.ChangeDisplaySettingsEx(deviceName, ref dm, 0, User_32.CDS_TEST, 0); 

            if (iRet != User_32.DISP_CHANGE_SUCCESSFUL) 
            { 
                return 2; 
            }

            iRet = User_32.ChangeDisplaySettingsEx(deviceName, ref dm, 0, User_32.CDS_UPDATEREGISTRY, 0);
            if (iRet != User_32.DISP_CHANGE_SUCCESSFUL) 
            { 
                return 3; 
            }


            return 0;
        }
		
        private static DEVMODE1 GetDevMode1() 
        { 
            DEVMODE1 dm = new DEVMODE1(); 
            dm.dmDeviceName = new String(new char[32]); 
            dm.dmFormName = new String(new char[32]); 
            dm.dmSize = (short)Marshal.SizeOf(dm); 
            return dm; 
        } 
    }
} 
"@
Add-Type $pinvokeCode

if($listDisplays) {
    [Resolution.Displays]::GetResolutions();
    [Resolution.Displays]::GetPositions();
    [Resolution.Displays]::GetProperties();
} else {
    Write-Host "Old:"
    [Resolution.Displays]::GetCurrentResolution($displayName);
    [Resolution.Displays]::GetCurrentPosition($displayName);
    [int]($toggleOrientation.substring(3)) / 90;
    if( [Resolution.Displays]::RotateDisplay($displayName, [int]($toggleOrientation.substring(3)) / 90, $alignRight, $preserveTop) -ne 0) {
        Write-Host ('Error rotating display "'+$displayName+'"');
    }
    Write-Host "New:"
    [Resolution.Displays]::GetCurrentResolution($displayName);
    [Resolution.Displays]::GetCurrentPosition($displayName);
}