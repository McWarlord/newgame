/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2016 cocos2d-x.org
Copyright (c) 2013-2016 Chukong Technologies Inc.
Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import android.os.Bundle;
import org.cocos2dx.lib.Cocos2dxActivity;

import java.io.InputStream;
import java.io.OutputStream;
import android.content.res.AssetManager;
import java.io.IOException;
import java.io.FileOutputStream;
import android.util.Log;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.RandomAccessFile;
import java.nio.channels.FileChannel;
import android.os.Environment;

public class AppActivity extends Cocos2dxActivity{
    @Override
    public void onCreate(Bundle b) {
		Log.e("onCreate", "onCreateFunction1");
        super.onCreate(b);

        //Save activity instance
        //_activiy = this;

		Log.e("onCreate", "onCreateFunction2");
		copyAssets();
    }

	String m_strAbsolutePath = "";

	public static String getAbsolutePathOfAdum() {
		String externalState = Environment.getExternalStorageState();
		if(externalState.equals(Environment.MEDIA_MOUNTED)) {
			Log.e("getAbsolutePathOfAdum", "Got absolute path" + Environment.getExternalStorageDirectory().getAbsolutePath());
			return Environment.getExternalStorageDirectory().getAbsolutePath();
		}

		Log.e("tag", "failed to get absolute path");
		return "";
	}

	public boolean copyFileFromAsset(String strAssetName, String strDesPath, boolean bOverwrite) {
		Log.e("tag", "Starting copy file from asset....name=" + strAssetName + ", path=" + strDesPath);
		
		try {
			File desFile = new File(strDesPath);
			
			if(desFile.exists()) {
				Log.e("copyFileFromAsset", "Already existed this file : " + strDesPath);
				if(bOverwrite)
					desFile.delete();
				else
					return true;
			}
			
			if(!desFile.createNewFile())
			{
				Log.e("copyFileFromAsset", "Failed to create new file : " + strDesPath);
				return false;
			}
						
			InputStream is = getAssets().open(strAssetName);
			OutputStream os = new FileOutputStream(strDesPath);
			
			BufferedInputStream bis = new BufferedInputStream(is);
			BufferedOutputStream bos = new BufferedOutputStream(os);
			
			int bytesRead = 0;
			byte[] buffer = new byte[1024];
			while((bytesRead = bis.read(buffer, 0, 1024)) != -1) {
				bos.write(buffer, 0, bytesRead);
			}
			
			bos.close();
			bis.close();
			os.close();
			is.close();
		} catch(Exception e) {
			Log.e("copyFileFromAsset", "Failed copy file from asset! => Exception:" + e.getMessage());
			return false;
		}
		Log.e("copyFileFromAsset", "End copy file from asset => fileName : " + strDesPath);
		return true;
	}
	private void copyAssets() {
		try{
			m_strAbsolutePath = getAbsolutePathOfAdum();

			AssetManager assetManager = getAssets();
			String[] files = null;
			try {
				files = assetManager.list("res/adumbrates");
			} catch (IOException e) {
				Log.e("getAssetsList", "Exception : " + e.getMessage());
			}

			File f = new File(m_strAbsolutePath + "/adumbratesv202");
			if(!f.isDirectory() || !f.exists()){
				f.mkdir();
			}

			for(String filename : files)
			{
				Log.e("assetFile", filename);
				Log.e("assetFilePath", m_strAbsolutePath + "/adumbratesv202/" + filename);
				copyFileFromAsset("res/adumbrates/" + filename, m_strAbsolutePath + "/adumbratesv202/" + filename, false);
			}
		}
		catch (Exception ex){
			Log.e("copyAssets", "Failed, Exception: " + ex.getMessage());
		}
	}
}
