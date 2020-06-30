// Amplify Impostors
// Copyright (c) Amplify Creations, Lda <info@amplify.pt>

using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
using System.Reflection;
using System;

namespace TgaUtil
{
	public static class BoundsEx
	{
		public static Bounds Transform( this Bounds bounds, Matrix4x4 matrix )
		{
			var center = matrix.MultiplyPoint3x4( bounds.center );
			var extents = bounds.extents;

			var axisX = matrix.MultiplyVector( new Vector3( extents.x, 0, 0 ) );
			var axisY = matrix.MultiplyVector( new Vector3( 0, extents.y, 0 ) );
			var axisZ = matrix.MultiplyVector( new Vector3( 0, 0, extents.z ) );

			extents.x = Mathf.Abs( axisX.x ) + Mathf.Abs( axisY.x ) + Mathf.Abs( axisZ.x );
			extents.y = Mathf.Abs( axisX.y ) + Mathf.Abs( axisY.y ) + Mathf.Abs( axisZ.y );
			extents.z = Mathf.Abs( axisX.z ) + Mathf.Abs( axisY.z ) + Mathf.Abs( axisZ.z );

			return new Bounds { center = center, extents = extents };
		}
	}
#if UNITY_EDITOR
	public static class MaterialEx
	{
		public static void CopyPropertiesFrom( this Material to, Material from )
		{
			
			int count = ShaderUtil.GetPropertyCount( from.shader );
			for( int i = 0; i < count; i++ )
			{
				var ty = ShaderUtil.GetPropertyType( from.shader, i );
				var name = ShaderUtil.GetPropertyName( from.shader, i );
				switch( ty )
				{
					case ShaderUtil.ShaderPropertyType.Color:
					to.SetColor( name, from.GetColor( name ) );
					break;
					case ShaderUtil.ShaderPropertyType.Vector:
					to.SetVector( name, from.GetVector( name ) );
					break;
					case ShaderUtil.ShaderPropertyType.Float:
					to.SetFloat( name, from.GetFloat( name ) );
					break;
					case ShaderUtil.ShaderPropertyType.Range:
					to.SetFloat( name, from.GetFloat( name ) );
					break;
					case ShaderUtil.ShaderPropertyType.TexEnv:
					to.SetTexture( name, from.GetTexture( name ) );
					to.SetTextureOffset( name, from.GetTextureOffset( name ) );
					to.SetTextureScale( name, from.GetTextureScale( name ) );
					break;
					default:
					break;
				}
			}
			to.renderQueue = from.renderQueue;
			to.globalIlluminationFlags = from.globalIlluminationFlags;
			to.shaderKeywords = from.shaderKeywords;
			to.enableInstancing = from.enableInstancing;
		}
	}
#endif
	//不知道为什么转RGBA32通道R和A是反的.
	public static class Texture2DEx
	{
		private static byte[] Footer = new byte[] { 0, 0, 0, 0, 0, 0, 0, 0, 84, 82, 85, 69, 86, 73, 83, 73, 79, 78, 45, 88, 70, 73, 76, 69, 46, 0 }; // TRUEVISION-XFILE. signature (new TGA format)

		// Uncompressed - TrueColor
		public static byte[] EncodeToTGA( this Texture2D tex, bool withAlpha = true )
		{
			int width = tex.width;
			int height = tex.height;
			Texture2D tex2 = new Texture2D(width,height,tex.format,false);
			var pixs = tex.GetPixels ();
			for (int i = 0; i < pixs.Length; i++) {
				pixs[i] = new Color(pixs[i].b,pixs[i].g,pixs[i].r,pixs[i].a);

			}
			tex2.SetPixels (pixs);
			tex2.Apply ();
			int elementCount = withAlpha ? 4 : 3;
			byte[] pixels = tex2.GetRawTextureData();
			GameObject.DestroyImmediate (tex2,true);
			int pixelLength = pixels.Length;



			int rawSize = elementCount * ( pixelLength / elementCount );

			int dataSize = rawSize;
			int footerSize = Footer.Length;

			int length = 18 + footerSize + dataSize;

			byte[] buffer = new byte[ length ];

			int index = 0;

			// Header
			buffer[ index++ ] = 0;
			buffer[ index++ ] = 0;
			buffer[ index++ ] = (byte)( 2 );
			buffer[ index++ ] = 0; buffer[ index++ ] = 0;
			buffer[ index++ ] = 0; buffer[ index++ ] = 0;
			buffer[ index++ ] = 0;
			buffer[ index++ ] = 0; buffer[ index++ ] = 0;
			buffer[ index++ ] = 0; buffer[ index++ ] = 0;
			buffer[ index++ ] = (byte)( ( width >> 0 ) & 0xFF );
			buffer[ index++ ] = (byte)( ( width >> 8 ) & 0xFF );
			buffer[ index++ ] = (byte)( ( height >> 0 ) & 0xFF );
			buffer[ index++ ] = (byte)( ( height >> 8 ) & 0xFF );
			buffer[ index++ ] = (byte)( 8 * elementCount );
			buffer[ index++ ] = 0;

			Array.Copy( pixels, 0, buffer, index, pixelLength );
			index += pixelLength;

			// Footer
			Array.Copy( Footer, 0, buffer, index, footerSize );

			return buffer;
		}
	}

 

	public static class Vector2Ex
	{
		public static float Cross( this Vector2 O, Vector2 A, Vector2 B )
		{
			return ( A.x - O.x ) * ( B.y - O.y ) - ( A.y - O.y ) * ( B.x - O.x );
		}

		public static float TriangleArea( this Vector2 O, Vector2 A, Vector2 B )
		{
			return Mathf.Abs( ( A.x - B.x ) * ( O.y - A.y ) - ( A.x - O.x ) * ( B.y - A.y ) ) * 0.5f;
		}

		public static float TriangleArea( this Vector3 O, Vector3 A, Vector3 B )
		{
			return Mathf.Abs( ( A.x - B.x ) * ( O.y - A.y ) - ( A.x - O.x ) * ( B.y - A.y ) ) * 0.5f;
		}

		public static Vector2[] ConvexHull( Vector2[] P )
		{
			if( P.Length > 1 )
			{
				int n = P.Length, k = 0;
				Vector2[] H = new Vector2[ 2 * n ];

				Comparison<Vector2> comparison = new Comparison<Vector2>( ( a, b ) =>
				{
					if( a.x == b.x )
						return a.y.CompareTo( b.y );
					else
						return a.x.CompareTo( b.x );
				} );
				Array.Sort<Vector2>( P, comparison );

				// Build lower hull
				for( int i = 0; i < n; ++i )
				{
					while( k >= 2 && P[ i ].Cross( H[ k - 2 ], H[ k - 1 ] ) <= 0 )
						k--;
					H[ k++ ] = P[ i ];
				}

				// Build upper hull
				for( int i = n - 2, t = k + 1; i >= 0; i-- )
				{
					while( k >= t && P[ i ].Cross( H[ k - 2 ], H[ k - 1 ] ) <= 0 )
						k--;
					H[ k++ ] = P[ i ];
				}
				if( k > 1 )
					Array.Resize<Vector2>( ref H, k - 1 );

				return H;
			}
			else if( P.Length <= 1 )
			{
				return P;
			}
			else
			{
				return null;
			}
		}

		public static Vector2[] ScaleAlongNormals( Vector2[] P, float scaleAmount )
		{
			Vector2[] normals = new Vector2[ P.Length ];
			for( int i = 0; i < normals.Length; i++ )
			{
				int prev = i - 1;
				int next = i + 1;
				if( i == 0 )
					prev = P.Length - 1;
				if( i == P.Length - 1 )
					next = 0;

				Vector2 ba = P[ i ] - P[ prev ];
				Vector2 bc = P[ i ] - P[ next ];
				Vector2 normal = ( ba.normalized + bc.normalized ).normalized;
				normals[ i ] = normal;
			}

			for( int i = 0; i < normals.Length; i++ )
			{
				P[ i ] = P[ i ] + normals[ i ] * scaleAmount;
			}

			return P;
		}
#if UNITY_EDITOR
		static Vector2[] ReduceLeastSignificantVertice( Vector2[] P )
		{
			float currentArea = 0;
			int smallestIndex = 0;
			int replacementIndex = 0;
			Vector2 newPos = Vector2.zero;
			for( int i = 0; i < P.Length; i++ )
			{
				int next = i + 1;
				int upNext = i + 2;
				int finalNext = i + 3;
				if( next >= P.Length )
					next -= P.Length;
				if( upNext >= P.Length )
					upNext -= P.Length;
				if( finalNext >= P.Length )
					finalNext -= P.Length;

				Vector2 intersect = GetIntersectionPointCoordinates( P[ i ], P[ next ], P[ upNext ], P[ finalNext ] );
				if( i == 0 )
				{
					currentArea = intersect.TriangleArea( P[ next ], P[ upNext ] );

					if( OutsideBounds( intersect ) > 0 )
						currentArea = currentArea + OutsideBounds( intersect ) * 1;

					smallestIndex = next;
					replacementIndex = upNext;
					newPos = intersect;
				}
				else
				{
					float newArea = intersect.TriangleArea( P[ next ], P[ upNext ] );

					if( OutsideBounds( intersect ) > 0 )
						newArea = newArea + OutsideBounds( intersect ) * 1;

					if( newArea < currentArea && OutsideBounds( intersect ) <= 0 )
					{
						currentArea = newArea;
						smallestIndex = next;
						replacementIndex = upNext;
						newPos = intersect;
					}
				}
			}

			P[ replacementIndex ] = newPos;
			ArrayUtility.RemoveAt<Vector2>( ref P, smallestIndex );
			return P;
		}


		public static Vector2[] ReduceVertices( Vector2[] P, int maxVertices )
		{
			if( maxVertices == 4 )
			{
				// turn into a box
				Rect newBox = new Rect( P[ 0 ].x, P[ 0 ].y, 0f, 0f );
				for( int i = 0; i < P.Length; i++ )
				{
					newBox.xMin = Mathf.Min( newBox.xMin, P[ i ].x );
					newBox.xMax = Mathf.Max( newBox.xMax, P[ i ].x );
					newBox.yMin = Mathf.Min( newBox.yMin, P[ i ].y );
					newBox.yMax = Mathf.Max( newBox.yMax, P[ i ].y );
				}

				P = new Vector2[]
				{
					new Vector2(newBox.xMin, newBox.yMin),
					new Vector2(newBox.xMax, newBox.yMin),
					new Vector2(newBox.xMax, newBox.yMax),
					new Vector2(newBox.xMin, newBox.yMax),
				};
			}
			else
			{
				// remove vertices to target count (naive implementation)
				int reduction = Math.Max( 0, P.Length - maxVertices );
				for( int k = 0; k < reduction; k++ )
				{
					P = ReduceLeastSignificantVertice( P );
					// OLD METHOD
					//float prevArea = 0;
					//int indexForRemoval = 0;
					//for( int i = 0; i < P.Length; i++ )
					//{
					//	int prev = i - 1;
					//	int next = i + 1;
					//	if( i == 0 )
					//		prev = P.Length - 1;
					//	if( i == P.Length - 1 )
					//		next = 0;

					//	float area = P[ i ].TriangleArea( P[ prev ], P[ next ] );
					//	if( i == 0 )
					//		prevArea = area;

					//	if( area < prevArea )
					//	{
					//		indexForRemoval = i;
					//		prevArea = area;
					//	}
					//}
					//ArrayUtility.RemoveAt<Vector2>( ref P, indexForRemoval );
				}
			}

			return P;
		}
#endif

		static Vector2 GetIntersectionPointCoordinates( Vector2 A1, Vector2 A2, Vector2 B1, Vector2 B2 )
		{
			float tmp = ( B2.x - B1.x ) * ( A2.y - A1.y ) - ( B2.y - B1.y ) * ( A2.x - A1.x );

			if( tmp == 0 )
			{
				return ( ( Vector2.Lerp( A2, B1, 0.5f ) - ( Vector2.one * 0.5f ) ) * 1000 ) + ( Vector2.one * 500f );//Vector2.positiveInfinity;// Vector2.zero;
			}

			float mu = ( ( A1.x - B1.x ) * ( A2.y - A1.y ) - ( A1.y - B1.y ) * ( A2.x - A1.x ) ) / tmp;

			return new Vector2(
				B1.x + ( B2.x - B1.x ) * mu,
				B1.y + ( B2.y - B1.y ) * mu
			);
		}

		static float OutsideBounds( Vector2 P )
		{
			P = P - ( Vector2.one * 0.5f );
			float vert = Mathf.Clamp01( Mathf.Abs( P.y ) - 0.5f );
			float hori = Mathf.Clamp01( Mathf.Abs( P.x ) - 0.5f );
			return hori + vert;
		}

	}
}
