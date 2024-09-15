(function(){const t=document.createElement("link").relList;if(t&&t.supports&&t.supports("modulepreload"))return;for(const r of document.querySelectorAll('link[rel="modulepreload"]'))n(r);new MutationObserver(r=>{for(const a of r)if(a.type==="childList")for(const o of a.addedNodes)o.tagName==="LINK"&&o.rel==="modulepreload"&&n(o)}).observe(document,{childList:!0,subtree:!0});function e(r){const a={};return r.integrity&&(a.integrity=r.integrity),r.referrerPolicy&&(a.referrerPolicy=r.referrerPolicy),r.crossOrigin==="use-credentials"?a.credentials="include":r.crossOrigin==="anonymous"?a.credentials="omit":a.credentials="same-origin",a}function n(r){if(r.ep)return;r.ep=!0;const a=e(r);fetch(r.href,a)}})();var ri=function(){var i=0,t=document.createElement("div");t.style.cssText="position:fixed;top:0;left:0;cursor:pointer;opacity:0.9;z-index:10000",t.addEventListener("click",function(u){u.preventDefault(),n(++i%t.children.length)},!1);function e(u){return t.appendChild(u.dom),u}function n(u){for(var d=0;d<t.children.length;d++)t.children[d].style.display=d===u?"block":"none";i=u}var r=(performance||Date).now(),a=r,o=0,s=e(new ri.Panel("FPS","#0ff","#002")),l=e(new ri.Panel("MS","#0f0","#020"));if(self.performance&&self.performance.memory)var c=e(new ri.Panel("MB","#f08","#201"));return n(0),{REVISION:16,dom:t,addPanel:e,showPanel:n,begin:function(){r=(performance||Date).now()},end:function(){o++;var u=(performance||Date).now();if(l.update(u-r,200),u>=a+1e3&&(s.update(o*1e3/(u-a),100),a=u,o=0,c)){var d=performance.memory;c.update(d.usedJSHeapSize/1048576,d.jsHeapSizeLimit/1048576)}return u},update:function(){r=this.end()},domElement:t,setMode:n}};ri.Panel=function(i,t,e){var n=1/0,r=0,a=Math.round,o=a(window.devicePixelRatio||1),s=80*o,l=48*o,c=3*o,u=2*o,d=3*o,f=15*o,m=74*o,v=30*o,_=document.createElement("canvas");_.width=s,_.height=l,_.style.cssText="width:80px;height:48px";var p=_.getContext("2d");return p.font="bold "+9*o+"px Helvetica,Arial,sans-serif",p.textBaseline="top",p.fillStyle=e,p.fillRect(0,0,s,l),p.fillStyle=t,p.fillText(i,c,u),p.fillRect(d,f,m,v),p.fillStyle=e,p.globalAlpha=.9,p.fillRect(d,f,m,v),{dom:_,update:function(h,E){n=Math.min(n,h),r=Math.max(r,h),p.fillStyle=e,p.globalAlpha=1,p.fillRect(0,0,s,f),p.fillStyle=t,p.fillText(a(h)+" "+i+" ("+a(n)+"-"+a(r)+")",c,u),p.drawImage(_,d+o,f,m-o,v,d,f,m-o,v),p.fillRect(d+m-o,f,o,v),p.fillStyle=e,p.globalAlpha=.9,p.fillRect(d+m-o,f,o,a((1-h/E)*v))}}};/**
 * @license
 * Copyright 2010-2023 Three.js Authors
 * SPDX-License-Identifier: MIT
 */const Xr="160",xo=0,sa=1,So=2,Cs=1,yo=2,qe=3,un=0,xe=1,Ye=2,on=0,Wn=1,oa=2,la=3,ca=4,To=5,yn=100,Mo=101,Eo=102,ua=103,ha=104,bo=200,Ao=201,wo=202,Ro=203,Ir=204,Nr=205,Co=206,Po=207,Lo=208,Do=209,Uo=210,Io=211,No=212,Fo=213,Oo=214,zo=0,Bo=1,Vo=2,Vi=3,Ho=4,Go=5,ko=6,Wo=7,Ps=0,Xo=1,qo=2,ln=0,Yo=1,$o=2,jo=3,Zo=4,Ko=5,Jo=6,Ls=300,qn=301,Yn=302,Fr=303,Or=304,qi=306,zr=1e3,Ee=1001,Br=1002,oe=1003,da=1004,er=1005,Re=1006,Qo=1007,si=1008,cn=1009,tl=1010,el=1011,qr=1012,Ds=1013,sn=1014,$e=1015,oi=1016,Us=1017,Is=1018,Mn=1020,nl=1021,Ce=1023,il=1024,rl=1025,En=1026,$n=1027,al=1028,Ns=1029,sl=1030,Fs=1031,Os=1033,nr=33776,ir=33777,rr=33778,ar=33779,fa=35840,pa=35841,ma=35842,ga=35843,zs=36196,_a=37492,va=37496,xa=37808,Sa=37809,ya=37810,Ta=37811,Ma=37812,Ea=37813,ba=37814,Aa=37815,wa=37816,Ra=37817,Ca=37818,Pa=37819,La=37820,Da=37821,sr=36492,Ua=36494,Ia=36495,ol=36283,Na=36284,Fa=36285,Oa=36286,Bs=3e3,bn=3001,ll=3200,cl=3201,ul=0,hl=1,Pe="",le="srgb",Je="srgb-linear",Yr="display-p3",Yi="display-p3-linear",Hi="linear",$t="srgb",Gi="rec709",ki="p3",An=7680,za=519,dl=512,fl=513,pl=514,Vs=515,ml=516,gl=517,_l=518,vl=519,Ba=35044,Va="300 es",Vr=1035,je=2e3,Wi=2001;class Zn{addEventListener(t,e){this._listeners===void 0&&(this._listeners={});const n=this._listeners;n[t]===void 0&&(n[t]=[]),n[t].indexOf(e)===-1&&n[t].push(e)}hasEventListener(t,e){if(this._listeners===void 0)return!1;const n=this._listeners;return n[t]!==void 0&&n[t].indexOf(e)!==-1}removeEventListener(t,e){if(this._listeners===void 0)return;const r=this._listeners[t];if(r!==void 0){const a=r.indexOf(e);a!==-1&&r.splice(a,1)}}dispatchEvent(t){if(this._listeners===void 0)return;const n=this._listeners[t.type];if(n!==void 0){t.target=this;const r=n.slice(0);for(let a=0,o=r.length;a<o;a++)r[a].call(this,t);t.target=null}}}const he=["00","01","02","03","04","05","06","07","08","09","0a","0b","0c","0d","0e","0f","10","11","12","13","14","15","16","17","18","19","1a","1b","1c","1d","1e","1f","20","21","22","23","24","25","26","27","28","29","2a","2b","2c","2d","2e","2f","30","31","32","33","34","35","36","37","38","39","3a","3b","3c","3d","3e","3f","40","41","42","43","44","45","46","47","48","49","4a","4b","4c","4d","4e","4f","50","51","52","53","54","55","56","57","58","59","5a","5b","5c","5d","5e","5f","60","61","62","63","64","65","66","67","68","69","6a","6b","6c","6d","6e","6f","70","71","72","73","74","75","76","77","78","79","7a","7b","7c","7d","7e","7f","80","81","82","83","84","85","86","87","88","89","8a","8b","8c","8d","8e","8f","90","91","92","93","94","95","96","97","98","99","9a","9b","9c","9d","9e","9f","a0","a1","a2","a3","a4","a5","a6","a7","a8","a9","aa","ab","ac","ad","ae","af","b0","b1","b2","b3","b4","b5","b6","b7","b8","b9","ba","bb","bc","bd","be","bf","c0","c1","c2","c3","c4","c5","c6","c7","c8","c9","ca","cb","cc","cd","ce","cf","d0","d1","d2","d3","d4","d5","d6","d7","d8","d9","da","db","dc","dd","de","df","e0","e1","e2","e3","e4","e5","e6","e7","e8","e9","ea","eb","ec","ed","ee","ef","f0","f1","f2","f3","f4","f5","f6","f7","f8","f9","fa","fb","fc","fd","fe","ff"],or=Math.PI/180,Hr=180/Math.PI;function ui(){const i=Math.random()*4294967295|0,t=Math.random()*4294967295|0,e=Math.random()*4294967295|0,n=Math.random()*4294967295|0;return(he[i&255]+he[i>>8&255]+he[i>>16&255]+he[i>>24&255]+"-"+he[t&255]+he[t>>8&255]+"-"+he[t>>16&15|64]+he[t>>24&255]+"-"+he[e&63|128]+he[e>>8&255]+"-"+he[e>>16&255]+he[e>>24&255]+he[n&255]+he[n>>8&255]+he[n>>16&255]+he[n>>24&255]).toLowerCase()}function ve(i,t,e){return Math.max(t,Math.min(e,i))}function xl(i,t){return(i%t+t)%t}function lr(i,t,e){return(1-e)*i+e*t}function Ha(i){return(i&i-1)===0&&i!==0}function Gr(i){return Math.pow(2,Math.floor(Math.log(i)/Math.LN2))}function Qn(i,t){switch(t.constructor){case Float32Array:return i;case Uint32Array:return i/4294967295;case Uint16Array:return i/65535;case Uint8Array:return i/255;case Int32Array:return Math.max(i/2147483647,-1);case Int16Array:return Math.max(i/32767,-1);case Int8Array:return Math.max(i/127,-1);default:throw new Error("Invalid component type.")}}function _e(i,t){switch(t.constructor){case Float32Array:return i;case Uint32Array:return Math.round(i*4294967295);case Uint16Array:return Math.round(i*65535);case Uint8Array:return Math.round(i*255);case Int32Array:return Math.round(i*2147483647);case Int16Array:return Math.round(i*32767);case Int8Array:return Math.round(i*127);default:throw new Error("Invalid component type.")}}class Wt{constructor(t=0,e=0){Wt.prototype.isVector2=!0,this.x=t,this.y=e}get width(){return this.x}set width(t){this.x=t}get height(){return this.y}set height(t){this.y=t}set(t,e){return this.x=t,this.y=e,this}setScalar(t){return this.x=t,this.y=t,this}setX(t){return this.x=t,this}setY(t){return this.y=t,this}setComponent(t,e){switch(t){case 0:this.x=e;break;case 1:this.y=e;break;default:throw new Error("index is out of range: "+t)}return this}getComponent(t){switch(t){case 0:return this.x;case 1:return this.y;default:throw new Error("index is out of range: "+t)}}clone(){return new this.constructor(this.x,this.y)}copy(t){return this.x=t.x,this.y=t.y,this}add(t){return this.x+=t.x,this.y+=t.y,this}addScalar(t){return this.x+=t,this.y+=t,this}addVectors(t,e){return this.x=t.x+e.x,this.y=t.y+e.y,this}addScaledVector(t,e){return this.x+=t.x*e,this.y+=t.y*e,this}sub(t){return this.x-=t.x,this.y-=t.y,this}subScalar(t){return this.x-=t,this.y-=t,this}subVectors(t,e){return this.x=t.x-e.x,this.y=t.y-e.y,this}multiply(t){return this.x*=t.x,this.y*=t.y,this}multiplyScalar(t){return this.x*=t,this.y*=t,this}divide(t){return this.x/=t.x,this.y/=t.y,this}divideScalar(t){return this.multiplyScalar(1/t)}applyMatrix3(t){const e=this.x,n=this.y,r=t.elements;return this.x=r[0]*e+r[3]*n+r[6],this.y=r[1]*e+r[4]*n+r[7],this}min(t){return this.x=Math.min(this.x,t.x),this.y=Math.min(this.y,t.y),this}max(t){return this.x=Math.max(this.x,t.x),this.y=Math.max(this.y,t.y),this}clamp(t,e){return this.x=Math.max(t.x,Math.min(e.x,this.x)),this.y=Math.max(t.y,Math.min(e.y,this.y)),this}clampScalar(t,e){return this.x=Math.max(t,Math.min(e,this.x)),this.y=Math.max(t,Math.min(e,this.y)),this}clampLength(t,e){const n=this.length();return this.divideScalar(n||1).multiplyScalar(Math.max(t,Math.min(e,n)))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this}negate(){return this.x=-this.x,this.y=-this.y,this}dot(t){return this.x*t.x+this.y*t.y}cross(t){return this.x*t.y-this.y*t.x}lengthSq(){return this.x*this.x+this.y*this.y}length(){return Math.sqrt(this.x*this.x+this.y*this.y)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)}normalize(){return this.divideScalar(this.length()||1)}angle(){return Math.atan2(-this.y,-this.x)+Math.PI}angleTo(t){const e=Math.sqrt(this.lengthSq()*t.lengthSq());if(e===0)return Math.PI/2;const n=this.dot(t)/e;return Math.acos(ve(n,-1,1))}distanceTo(t){return Math.sqrt(this.distanceToSquared(t))}distanceToSquared(t){const e=this.x-t.x,n=this.y-t.y;return e*e+n*n}manhattanDistanceTo(t){return Math.abs(this.x-t.x)+Math.abs(this.y-t.y)}setLength(t){return this.normalize().multiplyScalar(t)}lerp(t,e){return this.x+=(t.x-this.x)*e,this.y+=(t.y-this.y)*e,this}lerpVectors(t,e,n){return this.x=t.x+(e.x-t.x)*n,this.y=t.y+(e.y-t.y)*n,this}equals(t){return t.x===this.x&&t.y===this.y}fromArray(t,e=0){return this.x=t[e],this.y=t[e+1],this}toArray(t=[],e=0){return t[e]=this.x,t[e+1]=this.y,t}fromBufferAttribute(t,e){return this.x=t.getX(e),this.y=t.getY(e),this}rotateAround(t,e){const n=Math.cos(e),r=Math.sin(e),a=this.x-t.x,o=this.y-t.y;return this.x=a*n-o*r+t.x,this.y=a*r+o*n+t.y,this}random(){return this.x=Math.random(),this.y=Math.random(),this}*[Symbol.iterator](){yield this.x,yield this.y}}class Ct{constructor(t,e,n,r,a,o,s,l,c){Ct.prototype.isMatrix3=!0,this.elements=[1,0,0,0,1,0,0,0,1],t!==void 0&&this.set(t,e,n,r,a,o,s,l,c)}set(t,e,n,r,a,o,s,l,c){const u=this.elements;return u[0]=t,u[1]=r,u[2]=s,u[3]=e,u[4]=a,u[5]=l,u[6]=n,u[7]=o,u[8]=c,this}identity(){return this.set(1,0,0,0,1,0,0,0,1),this}copy(t){const e=this.elements,n=t.elements;return e[0]=n[0],e[1]=n[1],e[2]=n[2],e[3]=n[3],e[4]=n[4],e[5]=n[5],e[6]=n[6],e[7]=n[7],e[8]=n[8],this}extractBasis(t,e,n){return t.setFromMatrix3Column(this,0),e.setFromMatrix3Column(this,1),n.setFromMatrix3Column(this,2),this}setFromMatrix4(t){const e=t.elements;return this.set(e[0],e[4],e[8],e[1],e[5],e[9],e[2],e[6],e[10]),this}multiply(t){return this.multiplyMatrices(this,t)}premultiply(t){return this.multiplyMatrices(t,this)}multiplyMatrices(t,e){const n=t.elements,r=e.elements,a=this.elements,o=n[0],s=n[3],l=n[6],c=n[1],u=n[4],d=n[7],f=n[2],m=n[5],v=n[8],_=r[0],p=r[3],h=r[6],E=r[1],T=r[4],b=r[7],D=r[2],R=r[5],w=r[8];return a[0]=o*_+s*E+l*D,a[3]=o*p+s*T+l*R,a[6]=o*h+s*b+l*w,a[1]=c*_+u*E+d*D,a[4]=c*p+u*T+d*R,a[7]=c*h+u*b+d*w,a[2]=f*_+m*E+v*D,a[5]=f*p+m*T+v*R,a[8]=f*h+m*b+v*w,this}multiplyScalar(t){const e=this.elements;return e[0]*=t,e[3]*=t,e[6]*=t,e[1]*=t,e[4]*=t,e[7]*=t,e[2]*=t,e[5]*=t,e[8]*=t,this}determinant(){const t=this.elements,e=t[0],n=t[1],r=t[2],a=t[3],o=t[4],s=t[5],l=t[6],c=t[7],u=t[8];return e*o*u-e*s*c-n*a*u+n*s*l+r*a*c-r*o*l}invert(){const t=this.elements,e=t[0],n=t[1],r=t[2],a=t[3],o=t[4],s=t[5],l=t[6],c=t[7],u=t[8],d=u*o-s*c,f=s*l-u*a,m=c*a-o*l,v=e*d+n*f+r*m;if(v===0)return this.set(0,0,0,0,0,0,0,0,0);const _=1/v;return t[0]=d*_,t[1]=(r*c-u*n)*_,t[2]=(s*n-r*o)*_,t[3]=f*_,t[4]=(u*e-r*l)*_,t[5]=(r*a-s*e)*_,t[6]=m*_,t[7]=(n*l-c*e)*_,t[8]=(o*e-n*a)*_,this}transpose(){let t;const e=this.elements;return t=e[1],e[1]=e[3],e[3]=t,t=e[2],e[2]=e[6],e[6]=t,t=e[5],e[5]=e[7],e[7]=t,this}getNormalMatrix(t){return this.setFromMatrix4(t).invert().transpose()}transposeIntoArray(t){const e=this.elements;return t[0]=e[0],t[1]=e[3],t[2]=e[6],t[3]=e[1],t[4]=e[4],t[5]=e[7],t[6]=e[2],t[7]=e[5],t[8]=e[8],this}setUvTransform(t,e,n,r,a,o,s){const l=Math.cos(a),c=Math.sin(a);return this.set(n*l,n*c,-n*(l*o+c*s)+o+t,-r*c,r*l,-r*(-c*o+l*s)+s+e,0,0,1),this}scale(t,e){return this.premultiply(cr.makeScale(t,e)),this}rotate(t){return this.premultiply(cr.makeRotation(-t)),this}translate(t,e){return this.premultiply(cr.makeTranslation(t,e)),this}makeTranslation(t,e){return t.isVector2?this.set(1,0,t.x,0,1,t.y,0,0,1):this.set(1,0,t,0,1,e,0,0,1),this}makeRotation(t){const e=Math.cos(t),n=Math.sin(t);return this.set(e,-n,0,n,e,0,0,0,1),this}makeScale(t,e){return this.set(t,0,0,0,e,0,0,0,1),this}equals(t){const e=this.elements,n=t.elements;for(let r=0;r<9;r++)if(e[r]!==n[r])return!1;return!0}fromArray(t,e=0){for(let n=0;n<9;n++)this.elements[n]=t[n+e];return this}toArray(t=[],e=0){const n=this.elements;return t[e]=n[0],t[e+1]=n[1],t[e+2]=n[2],t[e+3]=n[3],t[e+4]=n[4],t[e+5]=n[5],t[e+6]=n[6],t[e+7]=n[7],t[e+8]=n[8],t}clone(){return new this.constructor().fromArray(this.elements)}}const cr=new Ct;function Hs(i){for(let t=i.length-1;t>=0;--t)if(i[t]>=65535)return!0;return!1}function li(i){return document.createElementNS("http://www.w3.org/1999/xhtml",i)}function Sl(){const i=li("canvas");return i.style.display="block",i}const Ga={};function ai(i){i in Ga||(Ga[i]=!0,console.warn(i))}const ka=new Ct().set(.8224621,.177538,0,.0331941,.9668058,0,.0170827,.0723974,.9105199),Wa=new Ct().set(1.2249401,-.2249404,0,-.0420569,1.0420571,0,-.0196376,-.0786361,1.0982735),gi={[Je]:{transfer:Hi,primaries:Gi,toReference:i=>i,fromReference:i=>i},[le]:{transfer:$t,primaries:Gi,toReference:i=>i.convertSRGBToLinear(),fromReference:i=>i.convertLinearToSRGB()},[Yi]:{transfer:Hi,primaries:ki,toReference:i=>i.applyMatrix3(Wa),fromReference:i=>i.applyMatrix3(ka)},[Yr]:{transfer:$t,primaries:ki,toReference:i=>i.convertSRGBToLinear().applyMatrix3(Wa),fromReference:i=>i.applyMatrix3(ka).convertLinearToSRGB()}},yl=new Set([Je,Yi]),Gt={enabled:!0,_workingColorSpace:Je,get workingColorSpace(){return this._workingColorSpace},set workingColorSpace(i){if(!yl.has(i))throw new Error(`Unsupported working color space, "${i}".`);this._workingColorSpace=i},convert:function(i,t,e){if(this.enabled===!1||t===e||!t||!e)return i;const n=gi[t].toReference,r=gi[e].fromReference;return r(n(i))},fromWorkingColorSpace:function(i,t){return this.convert(i,this._workingColorSpace,t)},toWorkingColorSpace:function(i,t){return this.convert(i,t,this._workingColorSpace)},getPrimaries:function(i){return gi[i].primaries},getTransfer:function(i){return i===Pe?Hi:gi[i].transfer}};function Xn(i){return i<.04045?i*.0773993808:Math.pow(i*.9478672986+.0521327014,2.4)}function ur(i){return i<.0031308?i*12.92:1.055*Math.pow(i,.41666)-.055}let wn;class Gs{static getDataURL(t){if(/^data:/i.test(t.src)||typeof HTMLCanvasElement>"u")return t.src;let e;if(t instanceof HTMLCanvasElement)e=t;else{wn===void 0&&(wn=li("canvas")),wn.width=t.width,wn.height=t.height;const n=wn.getContext("2d");t instanceof ImageData?n.putImageData(t,0,0):n.drawImage(t,0,0,t.width,t.height),e=wn}return e.width>2048||e.height>2048?(console.warn("THREE.ImageUtils.getDataURL: Image converted to jpg for performance reasons",t),e.toDataURL("image/jpeg",.6)):e.toDataURL("image/png")}static sRGBToLinear(t){if(typeof HTMLImageElement<"u"&&t instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&t instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&t instanceof ImageBitmap){const e=li("canvas");e.width=t.width,e.height=t.height;const n=e.getContext("2d");n.drawImage(t,0,0,t.width,t.height);const r=n.getImageData(0,0,t.width,t.height),a=r.data;for(let o=0;o<a.length;o++)a[o]=Xn(a[o]/255)*255;return n.putImageData(r,0,0),e}else if(t.data){const e=t.data.slice(0);for(let n=0;n<e.length;n++)e instanceof Uint8Array||e instanceof Uint8ClampedArray?e[n]=Math.floor(Xn(e[n]/255)*255):e[n]=Xn(e[n]);return{data:e,width:t.width,height:t.height}}else return console.warn("THREE.ImageUtils.sRGBToLinear(): Unsupported image type. No color space conversion applied."),t}}let Tl=0;class ks{constructor(t=null){this.isSource=!0,Object.defineProperty(this,"id",{value:Tl++}),this.uuid=ui(),this.data=t,this.version=0}set needsUpdate(t){t===!0&&this.version++}toJSON(t){const e=t===void 0||typeof t=="string";if(!e&&t.images[this.uuid]!==void 0)return t.images[this.uuid];const n={uuid:this.uuid,url:""},r=this.data;if(r!==null){let a;if(Array.isArray(r)){a=[];for(let o=0,s=r.length;o<s;o++)r[o].isDataTexture?a.push(hr(r[o].image)):a.push(hr(r[o]))}else a=hr(r);n.url=a}return e||(t.images[this.uuid]=n),n}}function hr(i){return typeof HTMLImageElement<"u"&&i instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&i instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&i instanceof ImageBitmap?Gs.getDataURL(i):i.data?{data:Array.from(i.data),width:i.width,height:i.height,type:i.data.constructor.name}:(console.warn("THREE.Texture: Unable to serialize Texture."),{})}let Ml=0;class Se extends Zn{constructor(t=Se.DEFAULT_IMAGE,e=Se.DEFAULT_MAPPING,n=Ee,r=Ee,a=Re,o=si,s=Ce,l=cn,c=Se.DEFAULT_ANISOTROPY,u=Pe){super(),this.isTexture=!0,Object.defineProperty(this,"id",{value:Ml++}),this.uuid=ui(),this.name="",this.source=new ks(t),this.mipmaps=[],this.mapping=e,this.channel=0,this.wrapS=n,this.wrapT=r,this.magFilter=a,this.minFilter=o,this.anisotropy=c,this.format=s,this.internalFormat=null,this.type=l,this.offset=new Wt(0,0),this.repeat=new Wt(1,1),this.center=new Wt(0,0),this.rotation=0,this.matrixAutoUpdate=!0,this.matrix=new Ct,this.generateMipmaps=!0,this.premultiplyAlpha=!1,this.flipY=!0,this.unpackAlignment=4,typeof u=="string"?this.colorSpace=u:(ai("THREE.Texture: Property .encoding has been replaced by .colorSpace."),this.colorSpace=u===bn?le:Pe),this.userData={},this.version=0,this.onUpdate=null,this.isRenderTargetTexture=!1,this.needsPMREMUpdate=!1}get image(){return this.source.data}set image(t=null){this.source.data=t}updateMatrix(){this.matrix.setUvTransform(this.offset.x,this.offset.y,this.repeat.x,this.repeat.y,this.rotation,this.center.x,this.center.y)}clone(){return new this.constructor().copy(this)}copy(t){return this.name=t.name,this.source=t.source,this.mipmaps=t.mipmaps.slice(0),this.mapping=t.mapping,this.channel=t.channel,this.wrapS=t.wrapS,this.wrapT=t.wrapT,this.magFilter=t.magFilter,this.minFilter=t.minFilter,this.anisotropy=t.anisotropy,this.format=t.format,this.internalFormat=t.internalFormat,this.type=t.type,this.offset.copy(t.offset),this.repeat.copy(t.repeat),this.center.copy(t.center),this.rotation=t.rotation,this.matrixAutoUpdate=t.matrixAutoUpdate,this.matrix.copy(t.matrix),this.generateMipmaps=t.generateMipmaps,this.premultiplyAlpha=t.premultiplyAlpha,this.flipY=t.flipY,this.unpackAlignment=t.unpackAlignment,this.colorSpace=t.colorSpace,this.userData=JSON.parse(JSON.stringify(t.userData)),this.needsUpdate=!0,this}toJSON(t){const e=t===void 0||typeof t=="string";if(!e&&t.textures[this.uuid]!==void 0)return t.textures[this.uuid];const n={metadata:{version:4.6,type:"Texture",generator:"Texture.toJSON"},uuid:this.uuid,name:this.name,image:this.source.toJSON(t).uuid,mapping:this.mapping,channel:this.channel,repeat:[this.repeat.x,this.repeat.y],offset:[this.offset.x,this.offset.y],center:[this.center.x,this.center.y],rotation:this.rotation,wrap:[this.wrapS,this.wrapT],format:this.format,internalFormat:this.internalFormat,type:this.type,colorSpace:this.colorSpace,minFilter:this.minFilter,magFilter:this.magFilter,anisotropy:this.anisotropy,flipY:this.flipY,generateMipmaps:this.generateMipmaps,premultiplyAlpha:this.premultiplyAlpha,unpackAlignment:this.unpackAlignment};return Object.keys(this.userData).length>0&&(n.userData=this.userData),e||(t.textures[this.uuid]=n),n}dispose(){this.dispatchEvent({type:"dispose"})}transformUv(t){if(this.mapping!==Ls)return t;if(t.applyMatrix3(this.matrix),t.x<0||t.x>1)switch(this.wrapS){case zr:t.x=t.x-Math.floor(t.x);break;case Ee:t.x=t.x<0?0:1;break;case Br:Math.abs(Math.floor(t.x)%2)===1?t.x=Math.ceil(t.x)-t.x:t.x=t.x-Math.floor(t.x);break}if(t.y<0||t.y>1)switch(this.wrapT){case zr:t.y=t.y-Math.floor(t.y);break;case Ee:t.y=t.y<0?0:1;break;case Br:Math.abs(Math.floor(t.y)%2)===1?t.y=Math.ceil(t.y)-t.y:t.y=t.y-Math.floor(t.y);break}return this.flipY&&(t.y=1-t.y),t}set needsUpdate(t){t===!0&&(this.version++,this.source.needsUpdate=!0)}get encoding(){return ai("THREE.Texture: Property .encoding has been replaced by .colorSpace."),this.colorSpace===le?bn:Bs}set encoding(t){ai("THREE.Texture: Property .encoding has been replaced by .colorSpace."),this.colorSpace=t===bn?le:Pe}}Se.DEFAULT_IMAGE=null;Se.DEFAULT_MAPPING=Ls;Se.DEFAULT_ANISOTROPY=1;class ce{constructor(t=0,e=0,n=0,r=1){ce.prototype.isVector4=!0,this.x=t,this.y=e,this.z=n,this.w=r}get width(){return this.z}set width(t){this.z=t}get height(){return this.w}set height(t){this.w=t}set(t,e,n,r){return this.x=t,this.y=e,this.z=n,this.w=r,this}setScalar(t){return this.x=t,this.y=t,this.z=t,this.w=t,this}setX(t){return this.x=t,this}setY(t){return this.y=t,this}setZ(t){return this.z=t,this}setW(t){return this.w=t,this}setComponent(t,e){switch(t){case 0:this.x=e;break;case 1:this.y=e;break;case 2:this.z=e;break;case 3:this.w=e;break;default:throw new Error("index is out of range: "+t)}return this}getComponent(t){switch(t){case 0:return this.x;case 1:return this.y;case 2:return this.z;case 3:return this.w;default:throw new Error("index is out of range: "+t)}}clone(){return new this.constructor(this.x,this.y,this.z,this.w)}copy(t){return this.x=t.x,this.y=t.y,this.z=t.z,this.w=t.w!==void 0?t.w:1,this}add(t){return this.x+=t.x,this.y+=t.y,this.z+=t.z,this.w+=t.w,this}addScalar(t){return this.x+=t,this.y+=t,this.z+=t,this.w+=t,this}addVectors(t,e){return this.x=t.x+e.x,this.y=t.y+e.y,this.z=t.z+e.z,this.w=t.w+e.w,this}addScaledVector(t,e){return this.x+=t.x*e,this.y+=t.y*e,this.z+=t.z*e,this.w+=t.w*e,this}sub(t){return this.x-=t.x,this.y-=t.y,this.z-=t.z,this.w-=t.w,this}subScalar(t){return this.x-=t,this.y-=t,this.z-=t,this.w-=t,this}subVectors(t,e){return this.x=t.x-e.x,this.y=t.y-e.y,this.z=t.z-e.z,this.w=t.w-e.w,this}multiply(t){return this.x*=t.x,this.y*=t.y,this.z*=t.z,this.w*=t.w,this}multiplyScalar(t){return this.x*=t,this.y*=t,this.z*=t,this.w*=t,this}applyMatrix4(t){const e=this.x,n=this.y,r=this.z,a=this.w,o=t.elements;return this.x=o[0]*e+o[4]*n+o[8]*r+o[12]*a,this.y=o[1]*e+o[5]*n+o[9]*r+o[13]*a,this.z=o[2]*e+o[6]*n+o[10]*r+o[14]*a,this.w=o[3]*e+o[7]*n+o[11]*r+o[15]*a,this}divideScalar(t){return this.multiplyScalar(1/t)}setAxisAngleFromQuaternion(t){this.w=2*Math.acos(t.w);const e=Math.sqrt(1-t.w*t.w);return e<1e-4?(this.x=1,this.y=0,this.z=0):(this.x=t.x/e,this.y=t.y/e,this.z=t.z/e),this}setAxisAngleFromRotationMatrix(t){let e,n,r,a;const l=t.elements,c=l[0],u=l[4],d=l[8],f=l[1],m=l[5],v=l[9],_=l[2],p=l[6],h=l[10];if(Math.abs(u-f)<.01&&Math.abs(d-_)<.01&&Math.abs(v-p)<.01){if(Math.abs(u+f)<.1&&Math.abs(d+_)<.1&&Math.abs(v+p)<.1&&Math.abs(c+m+h-3)<.1)return this.set(1,0,0,0),this;e=Math.PI;const T=(c+1)/2,b=(m+1)/2,D=(h+1)/2,R=(u+f)/4,w=(d+_)/4,Z=(v+p)/4;return T>b&&T>D?T<.01?(n=0,r=.707106781,a=.707106781):(n=Math.sqrt(T),r=R/n,a=w/n):b>D?b<.01?(n=.707106781,r=0,a=.707106781):(r=Math.sqrt(b),n=R/r,a=Z/r):D<.01?(n=.707106781,r=.707106781,a=0):(a=Math.sqrt(D),n=w/a,r=Z/a),this.set(n,r,a,e),this}let E=Math.sqrt((p-v)*(p-v)+(d-_)*(d-_)+(f-u)*(f-u));return Math.abs(E)<.001&&(E=1),this.x=(p-v)/E,this.y=(d-_)/E,this.z=(f-u)/E,this.w=Math.acos((c+m+h-1)/2),this}min(t){return this.x=Math.min(this.x,t.x),this.y=Math.min(this.y,t.y),this.z=Math.min(this.z,t.z),this.w=Math.min(this.w,t.w),this}max(t){return this.x=Math.max(this.x,t.x),this.y=Math.max(this.y,t.y),this.z=Math.max(this.z,t.z),this.w=Math.max(this.w,t.w),this}clamp(t,e){return this.x=Math.max(t.x,Math.min(e.x,this.x)),this.y=Math.max(t.y,Math.min(e.y,this.y)),this.z=Math.max(t.z,Math.min(e.z,this.z)),this.w=Math.max(t.w,Math.min(e.w,this.w)),this}clampScalar(t,e){return this.x=Math.max(t,Math.min(e,this.x)),this.y=Math.max(t,Math.min(e,this.y)),this.z=Math.max(t,Math.min(e,this.z)),this.w=Math.max(t,Math.min(e,this.w)),this}clampLength(t,e){const n=this.length();return this.divideScalar(n||1).multiplyScalar(Math.max(t,Math.min(e,n)))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this.z=Math.floor(this.z),this.w=Math.floor(this.w),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this.z=Math.ceil(this.z),this.w=Math.ceil(this.w),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this.z=Math.round(this.z),this.w=Math.round(this.w),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this.z=Math.trunc(this.z),this.w=Math.trunc(this.w),this}negate(){return this.x=-this.x,this.y=-this.y,this.z=-this.z,this.w=-this.w,this}dot(t){return this.x*t.x+this.y*t.y+this.z*t.z+this.w*t.w}lengthSq(){return this.x*this.x+this.y*this.y+this.z*this.z+this.w*this.w}length(){return Math.sqrt(this.x*this.x+this.y*this.y+this.z*this.z+this.w*this.w)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)+Math.abs(this.z)+Math.abs(this.w)}normalize(){return this.divideScalar(this.length()||1)}setLength(t){return this.normalize().multiplyScalar(t)}lerp(t,e){return this.x+=(t.x-this.x)*e,this.y+=(t.y-this.y)*e,this.z+=(t.z-this.z)*e,this.w+=(t.w-this.w)*e,this}lerpVectors(t,e,n){return this.x=t.x+(e.x-t.x)*n,this.y=t.y+(e.y-t.y)*n,this.z=t.z+(e.z-t.z)*n,this.w=t.w+(e.w-t.w)*n,this}equals(t){return t.x===this.x&&t.y===this.y&&t.z===this.z&&t.w===this.w}fromArray(t,e=0){return this.x=t[e],this.y=t[e+1],this.z=t[e+2],this.w=t[e+3],this}toArray(t=[],e=0){return t[e]=this.x,t[e+1]=this.y,t[e+2]=this.z,t[e+3]=this.w,t}fromBufferAttribute(t,e){return this.x=t.getX(e),this.y=t.getY(e),this.z=t.getZ(e),this.w=t.getW(e),this}random(){return this.x=Math.random(),this.y=Math.random(),this.z=Math.random(),this.w=Math.random(),this}*[Symbol.iterator](){yield this.x,yield this.y,yield this.z,yield this.w}}class El extends Zn{constructor(t=1,e=1,n={}){super(),this.isRenderTarget=!0,this.width=t,this.height=e,this.depth=1,this.scissor=new ce(0,0,t,e),this.scissorTest=!1,this.viewport=new ce(0,0,t,e);const r={width:t,height:e,depth:1};n.encoding!==void 0&&(ai("THREE.WebGLRenderTarget: option.encoding has been replaced by option.colorSpace."),n.colorSpace=n.encoding===bn?le:Pe),n=Object.assign({generateMipmaps:!1,internalFormat:null,minFilter:Re,depthBuffer:!0,stencilBuffer:!1,depthTexture:null,samples:0},n),this.texture=new Se(r,n.mapping,n.wrapS,n.wrapT,n.magFilter,n.minFilter,n.format,n.type,n.anisotropy,n.colorSpace),this.texture.isRenderTargetTexture=!0,this.texture.flipY=!1,this.texture.generateMipmaps=n.generateMipmaps,this.texture.internalFormat=n.internalFormat,this.depthBuffer=n.depthBuffer,this.stencilBuffer=n.stencilBuffer,this.depthTexture=n.depthTexture,this.samples=n.samples}setSize(t,e,n=1){(this.width!==t||this.height!==e||this.depth!==n)&&(this.width=t,this.height=e,this.depth=n,this.texture.image.width=t,this.texture.image.height=e,this.texture.image.depth=n,this.dispose()),this.viewport.set(0,0,t,e),this.scissor.set(0,0,t,e)}clone(){return new this.constructor().copy(this)}copy(t){this.width=t.width,this.height=t.height,this.depth=t.depth,this.scissor.copy(t.scissor),this.scissorTest=t.scissorTest,this.viewport.copy(t.viewport),this.texture=t.texture.clone(),this.texture.isRenderTargetTexture=!0;const e=Object.assign({},t.texture.image);return this.texture.source=new ks(e),this.depthBuffer=t.depthBuffer,this.stencilBuffer=t.stencilBuffer,t.depthTexture!==null&&(this.depthTexture=t.depthTexture.clone()),this.samples=t.samples,this}dispose(){this.dispatchEvent({type:"dispose"})}}class Qe extends El{constructor(t=1,e=1,n={}){super(t,e,n),this.isWebGLRenderTarget=!0}}class Ws extends Se{constructor(t=null,e=1,n=1,r=1){super(null),this.isDataArrayTexture=!0,this.image={data:t,width:e,height:n,depth:r},this.magFilter=oe,this.minFilter=oe,this.wrapR=Ee,this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1}}class bl extends Se{constructor(t=null,e=1,n=1,r=1){super(null),this.isData3DTexture=!0,this.image={data:t,width:e,height:n,depth:r},this.magFilter=oe,this.minFilter=oe,this.wrapR=Ee,this.generateMipmaps=!1,this.flipY=!1,this.unpackAlignment=1}}class hi{constructor(t=0,e=0,n=0,r=1){this.isQuaternion=!0,this._x=t,this._y=e,this._z=n,this._w=r}static slerpFlat(t,e,n,r,a,o,s){let l=n[r+0],c=n[r+1],u=n[r+2],d=n[r+3];const f=a[o+0],m=a[o+1],v=a[o+2],_=a[o+3];if(s===0){t[e+0]=l,t[e+1]=c,t[e+2]=u,t[e+3]=d;return}if(s===1){t[e+0]=f,t[e+1]=m,t[e+2]=v,t[e+3]=_;return}if(d!==_||l!==f||c!==m||u!==v){let p=1-s;const h=l*f+c*m+u*v+d*_,E=h>=0?1:-1,T=1-h*h;if(T>Number.EPSILON){const D=Math.sqrt(T),R=Math.atan2(D,h*E);p=Math.sin(p*R)/D,s=Math.sin(s*R)/D}const b=s*E;if(l=l*p+f*b,c=c*p+m*b,u=u*p+v*b,d=d*p+_*b,p===1-s){const D=1/Math.sqrt(l*l+c*c+u*u+d*d);l*=D,c*=D,u*=D,d*=D}}t[e]=l,t[e+1]=c,t[e+2]=u,t[e+3]=d}static multiplyQuaternionsFlat(t,e,n,r,a,o){const s=n[r],l=n[r+1],c=n[r+2],u=n[r+3],d=a[o],f=a[o+1],m=a[o+2],v=a[o+3];return t[e]=s*v+u*d+l*m-c*f,t[e+1]=l*v+u*f+c*d-s*m,t[e+2]=c*v+u*m+s*f-l*d,t[e+3]=u*v-s*d-l*f-c*m,t}get x(){return this._x}set x(t){this._x=t,this._onChangeCallback()}get y(){return this._y}set y(t){this._y=t,this._onChangeCallback()}get z(){return this._z}set z(t){this._z=t,this._onChangeCallback()}get w(){return this._w}set w(t){this._w=t,this._onChangeCallback()}set(t,e,n,r){return this._x=t,this._y=e,this._z=n,this._w=r,this._onChangeCallback(),this}clone(){return new this.constructor(this._x,this._y,this._z,this._w)}copy(t){return this._x=t.x,this._y=t.y,this._z=t.z,this._w=t.w,this._onChangeCallback(),this}setFromEuler(t,e=!0){const n=t._x,r=t._y,a=t._z,o=t._order,s=Math.cos,l=Math.sin,c=s(n/2),u=s(r/2),d=s(a/2),f=l(n/2),m=l(r/2),v=l(a/2);switch(o){case"XYZ":this._x=f*u*d+c*m*v,this._y=c*m*d-f*u*v,this._z=c*u*v+f*m*d,this._w=c*u*d-f*m*v;break;case"YXZ":this._x=f*u*d+c*m*v,this._y=c*m*d-f*u*v,this._z=c*u*v-f*m*d,this._w=c*u*d+f*m*v;break;case"ZXY":this._x=f*u*d-c*m*v,this._y=c*m*d+f*u*v,this._z=c*u*v+f*m*d,this._w=c*u*d-f*m*v;break;case"ZYX":this._x=f*u*d-c*m*v,this._y=c*m*d+f*u*v,this._z=c*u*v-f*m*d,this._w=c*u*d+f*m*v;break;case"YZX":this._x=f*u*d+c*m*v,this._y=c*m*d+f*u*v,this._z=c*u*v-f*m*d,this._w=c*u*d-f*m*v;break;case"XZY":this._x=f*u*d-c*m*v,this._y=c*m*d-f*u*v,this._z=c*u*v+f*m*d,this._w=c*u*d+f*m*v;break;default:console.warn("THREE.Quaternion: .setFromEuler() encountered an unknown order: "+o)}return e===!0&&this._onChangeCallback(),this}setFromAxisAngle(t,e){const n=e/2,r=Math.sin(n);return this._x=t.x*r,this._y=t.y*r,this._z=t.z*r,this._w=Math.cos(n),this._onChangeCallback(),this}setFromRotationMatrix(t){const e=t.elements,n=e[0],r=e[4],a=e[8],o=e[1],s=e[5],l=e[9],c=e[2],u=e[6],d=e[10],f=n+s+d;if(f>0){const m=.5/Math.sqrt(f+1);this._w=.25/m,this._x=(u-l)*m,this._y=(a-c)*m,this._z=(o-r)*m}else if(n>s&&n>d){const m=2*Math.sqrt(1+n-s-d);this._w=(u-l)/m,this._x=.25*m,this._y=(r+o)/m,this._z=(a+c)/m}else if(s>d){const m=2*Math.sqrt(1+s-n-d);this._w=(a-c)/m,this._x=(r+o)/m,this._y=.25*m,this._z=(l+u)/m}else{const m=2*Math.sqrt(1+d-n-s);this._w=(o-r)/m,this._x=(a+c)/m,this._y=(l+u)/m,this._z=.25*m}return this._onChangeCallback(),this}setFromUnitVectors(t,e){let n=t.dot(e)+1;return n<Number.EPSILON?(n=0,Math.abs(t.x)>Math.abs(t.z)?(this._x=-t.y,this._y=t.x,this._z=0,this._w=n):(this._x=0,this._y=-t.z,this._z=t.y,this._w=n)):(this._x=t.y*e.z-t.z*e.y,this._y=t.z*e.x-t.x*e.z,this._z=t.x*e.y-t.y*e.x,this._w=n),this.normalize()}angleTo(t){return 2*Math.acos(Math.abs(ve(this.dot(t),-1,1)))}rotateTowards(t,e){const n=this.angleTo(t);if(n===0)return this;const r=Math.min(1,e/n);return this.slerp(t,r),this}identity(){return this.set(0,0,0,1)}invert(){return this.conjugate()}conjugate(){return this._x*=-1,this._y*=-1,this._z*=-1,this._onChangeCallback(),this}dot(t){return this._x*t._x+this._y*t._y+this._z*t._z+this._w*t._w}lengthSq(){return this._x*this._x+this._y*this._y+this._z*this._z+this._w*this._w}length(){return Math.sqrt(this._x*this._x+this._y*this._y+this._z*this._z+this._w*this._w)}normalize(){let t=this.length();return t===0?(this._x=0,this._y=0,this._z=0,this._w=1):(t=1/t,this._x=this._x*t,this._y=this._y*t,this._z=this._z*t,this._w=this._w*t),this._onChangeCallback(),this}multiply(t){return this.multiplyQuaternions(this,t)}premultiply(t){return this.multiplyQuaternions(t,this)}multiplyQuaternions(t,e){const n=t._x,r=t._y,a=t._z,o=t._w,s=e._x,l=e._y,c=e._z,u=e._w;return this._x=n*u+o*s+r*c-a*l,this._y=r*u+o*l+a*s-n*c,this._z=a*u+o*c+n*l-r*s,this._w=o*u-n*s-r*l-a*c,this._onChangeCallback(),this}slerp(t,e){if(e===0)return this;if(e===1)return this.copy(t);const n=this._x,r=this._y,a=this._z,o=this._w;let s=o*t._w+n*t._x+r*t._y+a*t._z;if(s<0?(this._w=-t._w,this._x=-t._x,this._y=-t._y,this._z=-t._z,s=-s):this.copy(t),s>=1)return this._w=o,this._x=n,this._y=r,this._z=a,this;const l=1-s*s;if(l<=Number.EPSILON){const m=1-e;return this._w=m*o+e*this._w,this._x=m*n+e*this._x,this._y=m*r+e*this._y,this._z=m*a+e*this._z,this.normalize(),this}const c=Math.sqrt(l),u=Math.atan2(c,s),d=Math.sin((1-e)*u)/c,f=Math.sin(e*u)/c;return this._w=o*d+this._w*f,this._x=n*d+this._x*f,this._y=r*d+this._y*f,this._z=a*d+this._z*f,this._onChangeCallback(),this}slerpQuaternions(t,e,n){return this.copy(t).slerp(e,n)}random(){const t=Math.random(),e=Math.sqrt(1-t),n=Math.sqrt(t),r=2*Math.PI*Math.random(),a=2*Math.PI*Math.random();return this.set(e*Math.cos(r),n*Math.sin(a),n*Math.cos(a),e*Math.sin(r))}equals(t){return t._x===this._x&&t._y===this._y&&t._z===this._z&&t._w===this._w}fromArray(t,e=0){return this._x=t[e],this._y=t[e+1],this._z=t[e+2],this._w=t[e+3],this._onChangeCallback(),this}toArray(t=[],e=0){return t[e]=this._x,t[e+1]=this._y,t[e+2]=this._z,t[e+3]=this._w,t}fromBufferAttribute(t,e){return this._x=t.getX(e),this._y=t.getY(e),this._z=t.getZ(e),this._w=t.getW(e),this._onChangeCallback(),this}toJSON(){return this.toArray()}_onChange(t){return this._onChangeCallback=t,this}_onChangeCallback(){}*[Symbol.iterator](){yield this._x,yield this._y,yield this._z,yield this._w}}class L{constructor(t=0,e=0,n=0){L.prototype.isVector3=!0,this.x=t,this.y=e,this.z=n}set(t,e,n){return n===void 0&&(n=this.z),this.x=t,this.y=e,this.z=n,this}setScalar(t){return this.x=t,this.y=t,this.z=t,this}setX(t){return this.x=t,this}setY(t){return this.y=t,this}setZ(t){return this.z=t,this}setComponent(t,e){switch(t){case 0:this.x=e;break;case 1:this.y=e;break;case 2:this.z=e;break;default:throw new Error("index is out of range: "+t)}return this}getComponent(t){switch(t){case 0:return this.x;case 1:return this.y;case 2:return this.z;default:throw new Error("index is out of range: "+t)}}clone(){return new this.constructor(this.x,this.y,this.z)}copy(t){return this.x=t.x,this.y=t.y,this.z=t.z,this}add(t){return this.x+=t.x,this.y+=t.y,this.z+=t.z,this}addScalar(t){return this.x+=t,this.y+=t,this.z+=t,this}addVectors(t,e){return this.x=t.x+e.x,this.y=t.y+e.y,this.z=t.z+e.z,this}addScaledVector(t,e){return this.x+=t.x*e,this.y+=t.y*e,this.z+=t.z*e,this}sub(t){return this.x-=t.x,this.y-=t.y,this.z-=t.z,this}subScalar(t){return this.x-=t,this.y-=t,this.z-=t,this}subVectors(t,e){return this.x=t.x-e.x,this.y=t.y-e.y,this.z=t.z-e.z,this}multiply(t){return this.x*=t.x,this.y*=t.y,this.z*=t.z,this}multiplyScalar(t){return this.x*=t,this.y*=t,this.z*=t,this}multiplyVectors(t,e){return this.x=t.x*e.x,this.y=t.y*e.y,this.z=t.z*e.z,this}applyEuler(t){return this.applyQuaternion(Xa.setFromEuler(t))}applyAxisAngle(t,e){return this.applyQuaternion(Xa.setFromAxisAngle(t,e))}applyMatrix3(t){const e=this.x,n=this.y,r=this.z,a=t.elements;return this.x=a[0]*e+a[3]*n+a[6]*r,this.y=a[1]*e+a[4]*n+a[7]*r,this.z=a[2]*e+a[5]*n+a[8]*r,this}applyNormalMatrix(t){return this.applyMatrix3(t).normalize()}applyMatrix4(t){const e=this.x,n=this.y,r=this.z,a=t.elements,o=1/(a[3]*e+a[7]*n+a[11]*r+a[15]);return this.x=(a[0]*e+a[4]*n+a[8]*r+a[12])*o,this.y=(a[1]*e+a[5]*n+a[9]*r+a[13])*o,this.z=(a[2]*e+a[6]*n+a[10]*r+a[14])*o,this}applyQuaternion(t){const e=this.x,n=this.y,r=this.z,a=t.x,o=t.y,s=t.z,l=t.w,c=2*(o*r-s*n),u=2*(s*e-a*r),d=2*(a*n-o*e);return this.x=e+l*c+o*d-s*u,this.y=n+l*u+s*c-a*d,this.z=r+l*d+a*u-o*c,this}project(t){return this.applyMatrix4(t.matrixWorldInverse).applyMatrix4(t.projectionMatrix)}unproject(t){return this.applyMatrix4(t.projectionMatrixInverse).applyMatrix4(t.matrixWorld)}transformDirection(t){const e=this.x,n=this.y,r=this.z,a=t.elements;return this.x=a[0]*e+a[4]*n+a[8]*r,this.y=a[1]*e+a[5]*n+a[9]*r,this.z=a[2]*e+a[6]*n+a[10]*r,this.normalize()}divide(t){return this.x/=t.x,this.y/=t.y,this.z/=t.z,this}divideScalar(t){return this.multiplyScalar(1/t)}min(t){return this.x=Math.min(this.x,t.x),this.y=Math.min(this.y,t.y),this.z=Math.min(this.z,t.z),this}max(t){return this.x=Math.max(this.x,t.x),this.y=Math.max(this.y,t.y),this.z=Math.max(this.z,t.z),this}clamp(t,e){return this.x=Math.max(t.x,Math.min(e.x,this.x)),this.y=Math.max(t.y,Math.min(e.y,this.y)),this.z=Math.max(t.z,Math.min(e.z,this.z)),this}clampScalar(t,e){return this.x=Math.max(t,Math.min(e,this.x)),this.y=Math.max(t,Math.min(e,this.y)),this.z=Math.max(t,Math.min(e,this.z)),this}clampLength(t,e){const n=this.length();return this.divideScalar(n||1).multiplyScalar(Math.max(t,Math.min(e,n)))}floor(){return this.x=Math.floor(this.x),this.y=Math.floor(this.y),this.z=Math.floor(this.z),this}ceil(){return this.x=Math.ceil(this.x),this.y=Math.ceil(this.y),this.z=Math.ceil(this.z),this}round(){return this.x=Math.round(this.x),this.y=Math.round(this.y),this.z=Math.round(this.z),this}roundToZero(){return this.x=Math.trunc(this.x),this.y=Math.trunc(this.y),this.z=Math.trunc(this.z),this}negate(){return this.x=-this.x,this.y=-this.y,this.z=-this.z,this}dot(t){return this.x*t.x+this.y*t.y+this.z*t.z}lengthSq(){return this.x*this.x+this.y*this.y+this.z*this.z}length(){return Math.sqrt(this.x*this.x+this.y*this.y+this.z*this.z)}manhattanLength(){return Math.abs(this.x)+Math.abs(this.y)+Math.abs(this.z)}normalize(){return this.divideScalar(this.length()||1)}setLength(t){return this.normalize().multiplyScalar(t)}lerp(t,e){return this.x+=(t.x-this.x)*e,this.y+=(t.y-this.y)*e,this.z+=(t.z-this.z)*e,this}lerpVectors(t,e,n){return this.x=t.x+(e.x-t.x)*n,this.y=t.y+(e.y-t.y)*n,this.z=t.z+(e.z-t.z)*n,this}cross(t){return this.crossVectors(this,t)}crossVectors(t,e){const n=t.x,r=t.y,a=t.z,o=e.x,s=e.y,l=e.z;return this.x=r*l-a*s,this.y=a*o-n*l,this.z=n*s-r*o,this}projectOnVector(t){const e=t.lengthSq();if(e===0)return this.set(0,0,0);const n=t.dot(this)/e;return this.copy(t).multiplyScalar(n)}projectOnPlane(t){return dr.copy(this).projectOnVector(t),this.sub(dr)}reflect(t){return this.sub(dr.copy(t).multiplyScalar(2*this.dot(t)))}angleTo(t){const e=Math.sqrt(this.lengthSq()*t.lengthSq());if(e===0)return Math.PI/2;const n=this.dot(t)/e;return Math.acos(ve(n,-1,1))}distanceTo(t){return Math.sqrt(this.distanceToSquared(t))}distanceToSquared(t){const e=this.x-t.x,n=this.y-t.y,r=this.z-t.z;return e*e+n*n+r*r}manhattanDistanceTo(t){return Math.abs(this.x-t.x)+Math.abs(this.y-t.y)+Math.abs(this.z-t.z)}setFromSpherical(t){return this.setFromSphericalCoords(t.radius,t.phi,t.theta)}setFromSphericalCoords(t,e,n){const r=Math.sin(e)*t;return this.x=r*Math.sin(n),this.y=Math.cos(e)*t,this.z=r*Math.cos(n),this}setFromCylindrical(t){return this.setFromCylindricalCoords(t.radius,t.theta,t.y)}setFromCylindricalCoords(t,e,n){return this.x=t*Math.sin(e),this.y=n,this.z=t*Math.cos(e),this}setFromMatrixPosition(t){const e=t.elements;return this.x=e[12],this.y=e[13],this.z=e[14],this}setFromMatrixScale(t){const e=this.setFromMatrixColumn(t,0).length(),n=this.setFromMatrixColumn(t,1).length(),r=this.setFromMatrixColumn(t,2).length();return this.x=e,this.y=n,this.z=r,this}setFromMatrixColumn(t,e){return this.fromArray(t.elements,e*4)}setFromMatrix3Column(t,e){return this.fromArray(t.elements,e*3)}setFromEuler(t){return this.x=t._x,this.y=t._y,this.z=t._z,this}setFromColor(t){return this.x=t.r,this.y=t.g,this.z=t.b,this}equals(t){return t.x===this.x&&t.y===this.y&&t.z===this.z}fromArray(t,e=0){return this.x=t[e],this.y=t[e+1],this.z=t[e+2],this}toArray(t=[],e=0){return t[e]=this.x,t[e+1]=this.y,t[e+2]=this.z,t}fromBufferAttribute(t,e){return this.x=t.getX(e),this.y=t.getY(e),this.z=t.getZ(e),this}random(){return this.x=Math.random(),this.y=Math.random(),this.z=Math.random(),this}randomDirection(){const t=(Math.random()-.5)*2,e=Math.random()*Math.PI*2,n=Math.sqrt(1-t**2);return this.x=n*Math.cos(e),this.y=n*Math.sin(e),this.z=t,this}*[Symbol.iterator](){yield this.x,yield this.y,yield this.z}}const dr=new L,Xa=new hi;class di{constructor(t=new L(1/0,1/0,1/0),e=new L(-1/0,-1/0,-1/0)){this.isBox3=!0,this.min=t,this.max=e}set(t,e){return this.min.copy(t),this.max.copy(e),this}setFromArray(t){this.makeEmpty();for(let e=0,n=t.length;e<n;e+=3)this.expandByPoint(Le.fromArray(t,e));return this}setFromBufferAttribute(t){this.makeEmpty();for(let e=0,n=t.count;e<n;e++)this.expandByPoint(Le.fromBufferAttribute(t,e));return this}setFromPoints(t){this.makeEmpty();for(let e=0,n=t.length;e<n;e++)this.expandByPoint(t[e]);return this}setFromCenterAndSize(t,e){const n=Le.copy(e).multiplyScalar(.5);return this.min.copy(t).sub(n),this.max.copy(t).add(n),this}setFromObject(t,e=!1){return this.makeEmpty(),this.expandByObject(t,e)}clone(){return new this.constructor().copy(this)}copy(t){return this.min.copy(t.min),this.max.copy(t.max),this}makeEmpty(){return this.min.x=this.min.y=this.min.z=1/0,this.max.x=this.max.y=this.max.z=-1/0,this}isEmpty(){return this.max.x<this.min.x||this.max.y<this.min.y||this.max.z<this.min.z}getCenter(t){return this.isEmpty()?t.set(0,0,0):t.addVectors(this.min,this.max).multiplyScalar(.5)}getSize(t){return this.isEmpty()?t.set(0,0,0):t.subVectors(this.max,this.min)}expandByPoint(t){return this.min.min(t),this.max.max(t),this}expandByVector(t){return this.min.sub(t),this.max.add(t),this}expandByScalar(t){return this.min.addScalar(-t),this.max.addScalar(t),this}expandByObject(t,e=!1){t.updateWorldMatrix(!1,!1);const n=t.geometry;if(n!==void 0){const a=n.getAttribute("position");if(e===!0&&a!==void 0&&t.isInstancedMesh!==!0)for(let o=0,s=a.count;o<s;o++)t.isMesh===!0?t.getVertexPosition(o,Le):Le.fromBufferAttribute(a,o),Le.applyMatrix4(t.matrixWorld),this.expandByPoint(Le);else t.boundingBox!==void 0?(t.boundingBox===null&&t.computeBoundingBox(),_i.copy(t.boundingBox)):(n.boundingBox===null&&n.computeBoundingBox(),_i.copy(n.boundingBox)),_i.applyMatrix4(t.matrixWorld),this.union(_i)}const r=t.children;for(let a=0,o=r.length;a<o;a++)this.expandByObject(r[a],e);return this}containsPoint(t){return!(t.x<this.min.x||t.x>this.max.x||t.y<this.min.y||t.y>this.max.y||t.z<this.min.z||t.z>this.max.z)}containsBox(t){return this.min.x<=t.min.x&&t.max.x<=this.max.x&&this.min.y<=t.min.y&&t.max.y<=this.max.y&&this.min.z<=t.min.z&&t.max.z<=this.max.z}getParameter(t,e){return e.set((t.x-this.min.x)/(this.max.x-this.min.x),(t.y-this.min.y)/(this.max.y-this.min.y),(t.z-this.min.z)/(this.max.z-this.min.z))}intersectsBox(t){return!(t.max.x<this.min.x||t.min.x>this.max.x||t.max.y<this.min.y||t.min.y>this.max.y||t.max.z<this.min.z||t.min.z>this.max.z)}intersectsSphere(t){return this.clampPoint(t.center,Le),Le.distanceToSquared(t.center)<=t.radius*t.radius}intersectsPlane(t){let e,n;return t.normal.x>0?(e=t.normal.x*this.min.x,n=t.normal.x*this.max.x):(e=t.normal.x*this.max.x,n=t.normal.x*this.min.x),t.normal.y>0?(e+=t.normal.y*this.min.y,n+=t.normal.y*this.max.y):(e+=t.normal.y*this.max.y,n+=t.normal.y*this.min.y),t.normal.z>0?(e+=t.normal.z*this.min.z,n+=t.normal.z*this.max.z):(e+=t.normal.z*this.max.z,n+=t.normal.z*this.min.z),e<=-t.constant&&n>=-t.constant}intersectsTriangle(t){if(this.isEmpty())return!1;this.getCenter(ti),vi.subVectors(this.max,ti),Rn.subVectors(t.a,ti),Cn.subVectors(t.b,ti),Pn.subVectors(t.c,ti),tn.subVectors(Cn,Rn),en.subVectors(Pn,Cn),mn.subVectors(Rn,Pn);let e=[0,-tn.z,tn.y,0,-en.z,en.y,0,-mn.z,mn.y,tn.z,0,-tn.x,en.z,0,-en.x,mn.z,0,-mn.x,-tn.y,tn.x,0,-en.y,en.x,0,-mn.y,mn.x,0];return!fr(e,Rn,Cn,Pn,vi)||(e=[1,0,0,0,1,0,0,0,1],!fr(e,Rn,Cn,Pn,vi))?!1:(xi.crossVectors(tn,en),e=[xi.x,xi.y,xi.z],fr(e,Rn,Cn,Pn,vi))}clampPoint(t,e){return e.copy(t).clamp(this.min,this.max)}distanceToPoint(t){return this.clampPoint(t,Le).distanceTo(t)}getBoundingSphere(t){return this.isEmpty()?t.makeEmpty():(this.getCenter(t.center),t.radius=this.getSize(Le).length()*.5),t}intersect(t){return this.min.max(t.min),this.max.min(t.max),this.isEmpty()&&this.makeEmpty(),this}union(t){return this.min.min(t.min),this.max.max(t.max),this}applyMatrix4(t){return this.isEmpty()?this:(He[0].set(this.min.x,this.min.y,this.min.z).applyMatrix4(t),He[1].set(this.min.x,this.min.y,this.max.z).applyMatrix4(t),He[2].set(this.min.x,this.max.y,this.min.z).applyMatrix4(t),He[3].set(this.min.x,this.max.y,this.max.z).applyMatrix4(t),He[4].set(this.max.x,this.min.y,this.min.z).applyMatrix4(t),He[5].set(this.max.x,this.min.y,this.max.z).applyMatrix4(t),He[6].set(this.max.x,this.max.y,this.min.z).applyMatrix4(t),He[7].set(this.max.x,this.max.y,this.max.z).applyMatrix4(t),this.setFromPoints(He),this)}translate(t){return this.min.add(t),this.max.add(t),this}equals(t){return t.min.equals(this.min)&&t.max.equals(this.max)}}const He=[new L,new L,new L,new L,new L,new L,new L,new L],Le=new L,_i=new di,Rn=new L,Cn=new L,Pn=new L,tn=new L,en=new L,mn=new L,ti=new L,vi=new L,xi=new L,gn=new L;function fr(i,t,e,n,r){for(let a=0,o=i.length-3;a<=o;a+=3){gn.fromArray(i,a);const s=r.x*Math.abs(gn.x)+r.y*Math.abs(gn.y)+r.z*Math.abs(gn.z),l=t.dot(gn),c=e.dot(gn),u=n.dot(gn);if(Math.max(-Math.max(l,c,u),Math.min(l,c,u))>s)return!1}return!0}const Al=new di,ei=new L,pr=new L;class $r{constructor(t=new L,e=-1){this.isSphere=!0,this.center=t,this.radius=e}set(t,e){return this.center.copy(t),this.radius=e,this}setFromPoints(t,e){const n=this.center;e!==void 0?n.copy(e):Al.setFromPoints(t).getCenter(n);let r=0;for(let a=0,o=t.length;a<o;a++)r=Math.max(r,n.distanceToSquared(t[a]));return this.radius=Math.sqrt(r),this}copy(t){return this.center.copy(t.center),this.radius=t.radius,this}isEmpty(){return this.radius<0}makeEmpty(){return this.center.set(0,0,0),this.radius=-1,this}containsPoint(t){return t.distanceToSquared(this.center)<=this.radius*this.radius}distanceToPoint(t){return t.distanceTo(this.center)-this.radius}intersectsSphere(t){const e=this.radius+t.radius;return t.center.distanceToSquared(this.center)<=e*e}intersectsBox(t){return t.intersectsSphere(this)}intersectsPlane(t){return Math.abs(t.distanceToPoint(this.center))<=this.radius}clampPoint(t,e){const n=this.center.distanceToSquared(t);return e.copy(t),n>this.radius*this.radius&&(e.sub(this.center).normalize(),e.multiplyScalar(this.radius).add(this.center)),e}getBoundingBox(t){return this.isEmpty()?(t.makeEmpty(),t):(t.set(this.center,this.center),t.expandByScalar(this.radius),t)}applyMatrix4(t){return this.center.applyMatrix4(t),this.radius=this.radius*t.getMaxScaleOnAxis(),this}translate(t){return this.center.add(t),this}expandByPoint(t){if(this.isEmpty())return this.center.copy(t),this.radius=0,this;ei.subVectors(t,this.center);const e=ei.lengthSq();if(e>this.radius*this.radius){const n=Math.sqrt(e),r=(n-this.radius)*.5;this.center.addScaledVector(ei,r/n),this.radius+=r}return this}union(t){return t.isEmpty()?this:this.isEmpty()?(this.copy(t),this):(this.center.equals(t.center)===!0?this.radius=Math.max(this.radius,t.radius):(pr.subVectors(t.center,this.center).setLength(t.radius),this.expandByPoint(ei.copy(t.center).add(pr)),this.expandByPoint(ei.copy(t.center).sub(pr))),this)}equals(t){return t.center.equals(this.center)&&t.radius===this.radius}clone(){return new this.constructor().copy(this)}}const Ge=new L,mr=new L,Si=new L,nn=new L,gr=new L,yi=new L,_r=new L;class wl{constructor(t=new L,e=new L(0,0,-1)){this.origin=t,this.direction=e}set(t,e){return this.origin.copy(t),this.direction.copy(e),this}copy(t){return this.origin.copy(t.origin),this.direction.copy(t.direction),this}at(t,e){return e.copy(this.origin).addScaledVector(this.direction,t)}lookAt(t){return this.direction.copy(t).sub(this.origin).normalize(),this}recast(t){return this.origin.copy(this.at(t,Ge)),this}closestPointToPoint(t,e){e.subVectors(t,this.origin);const n=e.dot(this.direction);return n<0?e.copy(this.origin):e.copy(this.origin).addScaledVector(this.direction,n)}distanceToPoint(t){return Math.sqrt(this.distanceSqToPoint(t))}distanceSqToPoint(t){const e=Ge.subVectors(t,this.origin).dot(this.direction);return e<0?this.origin.distanceToSquared(t):(Ge.copy(this.origin).addScaledVector(this.direction,e),Ge.distanceToSquared(t))}distanceSqToSegment(t,e,n,r){mr.copy(t).add(e).multiplyScalar(.5),Si.copy(e).sub(t).normalize(),nn.copy(this.origin).sub(mr);const a=t.distanceTo(e)*.5,o=-this.direction.dot(Si),s=nn.dot(this.direction),l=-nn.dot(Si),c=nn.lengthSq(),u=Math.abs(1-o*o);let d,f,m,v;if(u>0)if(d=o*l-s,f=o*s-l,v=a*u,d>=0)if(f>=-v)if(f<=v){const _=1/u;d*=_,f*=_,m=d*(d+o*f+2*s)+f*(o*d+f+2*l)+c}else f=a,d=Math.max(0,-(o*f+s)),m=-d*d+f*(f+2*l)+c;else f=-a,d=Math.max(0,-(o*f+s)),m=-d*d+f*(f+2*l)+c;else f<=-v?(d=Math.max(0,-(-o*a+s)),f=d>0?-a:Math.min(Math.max(-a,-l),a),m=-d*d+f*(f+2*l)+c):f<=v?(d=0,f=Math.min(Math.max(-a,-l),a),m=f*(f+2*l)+c):(d=Math.max(0,-(o*a+s)),f=d>0?a:Math.min(Math.max(-a,-l),a),m=-d*d+f*(f+2*l)+c);else f=o>0?-a:a,d=Math.max(0,-(o*f+s)),m=-d*d+f*(f+2*l)+c;return n&&n.copy(this.origin).addScaledVector(this.direction,d),r&&r.copy(mr).addScaledVector(Si,f),m}intersectSphere(t,e){Ge.subVectors(t.center,this.origin);const n=Ge.dot(this.direction),r=Ge.dot(Ge)-n*n,a=t.radius*t.radius;if(r>a)return null;const o=Math.sqrt(a-r),s=n-o,l=n+o;return l<0?null:s<0?this.at(l,e):this.at(s,e)}intersectsSphere(t){return this.distanceSqToPoint(t.center)<=t.radius*t.radius}distanceToPlane(t){const e=t.normal.dot(this.direction);if(e===0)return t.distanceToPoint(this.origin)===0?0:null;const n=-(this.origin.dot(t.normal)+t.constant)/e;return n>=0?n:null}intersectPlane(t,e){const n=this.distanceToPlane(t);return n===null?null:this.at(n,e)}intersectsPlane(t){const e=t.distanceToPoint(this.origin);return e===0||t.normal.dot(this.direction)*e<0}intersectBox(t,e){let n,r,a,o,s,l;const c=1/this.direction.x,u=1/this.direction.y,d=1/this.direction.z,f=this.origin;return c>=0?(n=(t.min.x-f.x)*c,r=(t.max.x-f.x)*c):(n=(t.max.x-f.x)*c,r=(t.min.x-f.x)*c),u>=0?(a=(t.min.y-f.y)*u,o=(t.max.y-f.y)*u):(a=(t.max.y-f.y)*u,o=(t.min.y-f.y)*u),n>o||a>r||((a>n||isNaN(n))&&(n=a),(o<r||isNaN(r))&&(r=o),d>=0?(s=(t.min.z-f.z)*d,l=(t.max.z-f.z)*d):(s=(t.max.z-f.z)*d,l=(t.min.z-f.z)*d),n>l||s>r)||((s>n||n!==n)&&(n=s),(l<r||r!==r)&&(r=l),r<0)?null:this.at(n>=0?n:r,e)}intersectsBox(t){return this.intersectBox(t,Ge)!==null}intersectTriangle(t,e,n,r,a){gr.subVectors(e,t),yi.subVectors(n,t),_r.crossVectors(gr,yi);let o=this.direction.dot(_r),s;if(o>0){if(r)return null;s=1}else if(o<0)s=-1,o=-o;else return null;nn.subVectors(this.origin,t);const l=s*this.direction.dot(yi.crossVectors(nn,yi));if(l<0)return null;const c=s*this.direction.dot(gr.cross(nn));if(c<0||l+c>o)return null;const u=-s*nn.dot(_r);return u<0?null:this.at(u/o,a)}applyMatrix4(t){return this.origin.applyMatrix4(t),this.direction.transformDirection(t),this}equals(t){return t.origin.equals(this.origin)&&t.direction.equals(this.direction)}clone(){return new this.constructor().copy(this)}}class Kt{constructor(t,e,n,r,a,o,s,l,c,u,d,f,m,v,_,p){Kt.prototype.isMatrix4=!0,this.elements=[1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1],t!==void 0&&this.set(t,e,n,r,a,o,s,l,c,u,d,f,m,v,_,p)}set(t,e,n,r,a,o,s,l,c,u,d,f,m,v,_,p){const h=this.elements;return h[0]=t,h[4]=e,h[8]=n,h[12]=r,h[1]=a,h[5]=o,h[9]=s,h[13]=l,h[2]=c,h[6]=u,h[10]=d,h[14]=f,h[3]=m,h[7]=v,h[11]=_,h[15]=p,this}identity(){return this.set(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1),this}clone(){return new Kt().fromArray(this.elements)}copy(t){const e=this.elements,n=t.elements;return e[0]=n[0],e[1]=n[1],e[2]=n[2],e[3]=n[3],e[4]=n[4],e[5]=n[5],e[6]=n[6],e[7]=n[7],e[8]=n[8],e[9]=n[9],e[10]=n[10],e[11]=n[11],e[12]=n[12],e[13]=n[13],e[14]=n[14],e[15]=n[15],this}copyPosition(t){const e=this.elements,n=t.elements;return e[12]=n[12],e[13]=n[13],e[14]=n[14],this}setFromMatrix3(t){const e=t.elements;return this.set(e[0],e[3],e[6],0,e[1],e[4],e[7],0,e[2],e[5],e[8],0,0,0,0,1),this}extractBasis(t,e,n){return t.setFromMatrixColumn(this,0),e.setFromMatrixColumn(this,1),n.setFromMatrixColumn(this,2),this}makeBasis(t,e,n){return this.set(t.x,e.x,n.x,0,t.y,e.y,n.y,0,t.z,e.z,n.z,0,0,0,0,1),this}extractRotation(t){const e=this.elements,n=t.elements,r=1/Ln.setFromMatrixColumn(t,0).length(),a=1/Ln.setFromMatrixColumn(t,1).length(),o=1/Ln.setFromMatrixColumn(t,2).length();return e[0]=n[0]*r,e[1]=n[1]*r,e[2]=n[2]*r,e[3]=0,e[4]=n[4]*a,e[5]=n[5]*a,e[6]=n[6]*a,e[7]=0,e[8]=n[8]*o,e[9]=n[9]*o,e[10]=n[10]*o,e[11]=0,e[12]=0,e[13]=0,e[14]=0,e[15]=1,this}makeRotationFromEuler(t){const e=this.elements,n=t.x,r=t.y,a=t.z,o=Math.cos(n),s=Math.sin(n),l=Math.cos(r),c=Math.sin(r),u=Math.cos(a),d=Math.sin(a);if(t.order==="XYZ"){const f=o*u,m=o*d,v=s*u,_=s*d;e[0]=l*u,e[4]=-l*d,e[8]=c,e[1]=m+v*c,e[5]=f-_*c,e[9]=-s*l,e[2]=_-f*c,e[6]=v+m*c,e[10]=o*l}else if(t.order==="YXZ"){const f=l*u,m=l*d,v=c*u,_=c*d;e[0]=f+_*s,e[4]=v*s-m,e[8]=o*c,e[1]=o*d,e[5]=o*u,e[9]=-s,e[2]=m*s-v,e[6]=_+f*s,e[10]=o*l}else if(t.order==="ZXY"){const f=l*u,m=l*d,v=c*u,_=c*d;e[0]=f-_*s,e[4]=-o*d,e[8]=v+m*s,e[1]=m+v*s,e[5]=o*u,e[9]=_-f*s,e[2]=-o*c,e[6]=s,e[10]=o*l}else if(t.order==="ZYX"){const f=o*u,m=o*d,v=s*u,_=s*d;e[0]=l*u,e[4]=v*c-m,e[8]=f*c+_,e[1]=l*d,e[5]=_*c+f,e[9]=m*c-v,e[2]=-c,e[6]=s*l,e[10]=o*l}else if(t.order==="YZX"){const f=o*l,m=o*c,v=s*l,_=s*c;e[0]=l*u,e[4]=_-f*d,e[8]=v*d+m,e[1]=d,e[5]=o*u,e[9]=-s*u,e[2]=-c*u,e[6]=m*d+v,e[10]=f-_*d}else if(t.order==="XZY"){const f=o*l,m=o*c,v=s*l,_=s*c;e[0]=l*u,e[4]=-d,e[8]=c*u,e[1]=f*d+_,e[5]=o*u,e[9]=m*d-v,e[2]=v*d-m,e[6]=s*u,e[10]=_*d+f}return e[3]=0,e[7]=0,e[11]=0,e[12]=0,e[13]=0,e[14]=0,e[15]=1,this}makeRotationFromQuaternion(t){return this.compose(Rl,t,Cl)}lookAt(t,e,n){const r=this.elements;return Te.subVectors(t,e),Te.lengthSq()===0&&(Te.z=1),Te.normalize(),rn.crossVectors(n,Te),rn.lengthSq()===0&&(Math.abs(n.z)===1?Te.x+=1e-4:Te.z+=1e-4,Te.normalize(),rn.crossVectors(n,Te)),rn.normalize(),Ti.crossVectors(Te,rn),r[0]=rn.x,r[4]=Ti.x,r[8]=Te.x,r[1]=rn.y,r[5]=Ti.y,r[9]=Te.y,r[2]=rn.z,r[6]=Ti.z,r[10]=Te.z,this}multiply(t){return this.multiplyMatrices(this,t)}premultiply(t){return this.multiplyMatrices(t,this)}multiplyMatrices(t,e){const n=t.elements,r=e.elements,a=this.elements,o=n[0],s=n[4],l=n[8],c=n[12],u=n[1],d=n[5],f=n[9],m=n[13],v=n[2],_=n[6],p=n[10],h=n[14],E=n[3],T=n[7],b=n[11],D=n[15],R=r[0],w=r[4],Z=r[8],y=r[12],M=r[1],H=r[5],k=r[9],it=r[13],C=r[2],z=r[6],V=r[10],X=r[14],G=r[3],W=r[7],q=r[11],Q=r[15];return a[0]=o*R+s*M+l*C+c*G,a[4]=o*w+s*H+l*z+c*W,a[8]=o*Z+s*k+l*V+c*q,a[12]=o*y+s*it+l*X+c*Q,a[1]=u*R+d*M+f*C+m*G,a[5]=u*w+d*H+f*z+m*W,a[9]=u*Z+d*k+f*V+m*q,a[13]=u*y+d*it+f*X+m*Q,a[2]=v*R+_*M+p*C+h*G,a[6]=v*w+_*H+p*z+h*W,a[10]=v*Z+_*k+p*V+h*q,a[14]=v*y+_*it+p*X+h*Q,a[3]=E*R+T*M+b*C+D*G,a[7]=E*w+T*H+b*z+D*W,a[11]=E*Z+T*k+b*V+D*q,a[15]=E*y+T*it+b*X+D*Q,this}multiplyScalar(t){const e=this.elements;return e[0]*=t,e[4]*=t,e[8]*=t,e[12]*=t,e[1]*=t,e[5]*=t,e[9]*=t,e[13]*=t,e[2]*=t,e[6]*=t,e[10]*=t,e[14]*=t,e[3]*=t,e[7]*=t,e[11]*=t,e[15]*=t,this}determinant(){const t=this.elements,e=t[0],n=t[4],r=t[8],a=t[12],o=t[1],s=t[5],l=t[9],c=t[13],u=t[2],d=t[6],f=t[10],m=t[14],v=t[3],_=t[7],p=t[11],h=t[15];return v*(+a*l*d-r*c*d-a*s*f+n*c*f+r*s*m-n*l*m)+_*(+e*l*m-e*c*f+a*o*f-r*o*m+r*c*u-a*l*u)+p*(+e*c*d-e*s*m-a*o*d+n*o*m+a*s*u-n*c*u)+h*(-r*s*u-e*l*d+e*s*f+r*o*d-n*o*f+n*l*u)}transpose(){const t=this.elements;let e;return e=t[1],t[1]=t[4],t[4]=e,e=t[2],t[2]=t[8],t[8]=e,e=t[6],t[6]=t[9],t[9]=e,e=t[3],t[3]=t[12],t[12]=e,e=t[7],t[7]=t[13],t[13]=e,e=t[11],t[11]=t[14],t[14]=e,this}setPosition(t,e,n){const r=this.elements;return t.isVector3?(r[12]=t.x,r[13]=t.y,r[14]=t.z):(r[12]=t,r[13]=e,r[14]=n),this}invert(){const t=this.elements,e=t[0],n=t[1],r=t[2],a=t[3],o=t[4],s=t[5],l=t[6],c=t[7],u=t[8],d=t[9],f=t[10],m=t[11],v=t[12],_=t[13],p=t[14],h=t[15],E=d*p*c-_*f*c+_*l*m-s*p*m-d*l*h+s*f*h,T=v*f*c-u*p*c-v*l*m+o*p*m+u*l*h-o*f*h,b=u*_*c-v*d*c+v*s*m-o*_*m-u*s*h+o*d*h,D=v*d*l-u*_*l-v*s*f+o*_*f+u*s*p-o*d*p,R=e*E+n*T+r*b+a*D;if(R===0)return this.set(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);const w=1/R;return t[0]=E*w,t[1]=(_*f*a-d*p*a-_*r*m+n*p*m+d*r*h-n*f*h)*w,t[2]=(s*p*a-_*l*a+_*r*c-n*p*c-s*r*h+n*l*h)*w,t[3]=(d*l*a-s*f*a-d*r*c+n*f*c+s*r*m-n*l*m)*w,t[4]=T*w,t[5]=(u*p*a-v*f*a+v*r*m-e*p*m-u*r*h+e*f*h)*w,t[6]=(v*l*a-o*p*a-v*r*c+e*p*c+o*r*h-e*l*h)*w,t[7]=(o*f*a-u*l*a+u*r*c-e*f*c-o*r*m+e*l*m)*w,t[8]=b*w,t[9]=(v*d*a-u*_*a-v*n*m+e*_*m+u*n*h-e*d*h)*w,t[10]=(o*_*a-v*s*a+v*n*c-e*_*c-o*n*h+e*s*h)*w,t[11]=(u*s*a-o*d*a-u*n*c+e*d*c+o*n*m-e*s*m)*w,t[12]=D*w,t[13]=(u*_*r-v*d*r+v*n*f-e*_*f-u*n*p+e*d*p)*w,t[14]=(v*s*r-o*_*r-v*n*l+e*_*l+o*n*p-e*s*p)*w,t[15]=(o*d*r-u*s*r+u*n*l-e*d*l-o*n*f+e*s*f)*w,this}scale(t){const e=this.elements,n=t.x,r=t.y,a=t.z;return e[0]*=n,e[4]*=r,e[8]*=a,e[1]*=n,e[5]*=r,e[9]*=a,e[2]*=n,e[6]*=r,e[10]*=a,e[3]*=n,e[7]*=r,e[11]*=a,this}getMaxScaleOnAxis(){const t=this.elements,e=t[0]*t[0]+t[1]*t[1]+t[2]*t[2],n=t[4]*t[4]+t[5]*t[5]+t[6]*t[6],r=t[8]*t[8]+t[9]*t[9]+t[10]*t[10];return Math.sqrt(Math.max(e,n,r))}makeTranslation(t,e,n){return t.isVector3?this.set(1,0,0,t.x,0,1,0,t.y,0,0,1,t.z,0,0,0,1):this.set(1,0,0,t,0,1,0,e,0,0,1,n,0,0,0,1),this}makeRotationX(t){const e=Math.cos(t),n=Math.sin(t);return this.set(1,0,0,0,0,e,-n,0,0,n,e,0,0,0,0,1),this}makeRotationY(t){const e=Math.cos(t),n=Math.sin(t);return this.set(e,0,n,0,0,1,0,0,-n,0,e,0,0,0,0,1),this}makeRotationZ(t){const e=Math.cos(t),n=Math.sin(t);return this.set(e,-n,0,0,n,e,0,0,0,0,1,0,0,0,0,1),this}makeRotationAxis(t,e){const n=Math.cos(e),r=Math.sin(e),a=1-n,o=t.x,s=t.y,l=t.z,c=a*o,u=a*s;return this.set(c*o+n,c*s-r*l,c*l+r*s,0,c*s+r*l,u*s+n,u*l-r*o,0,c*l-r*s,u*l+r*o,a*l*l+n,0,0,0,0,1),this}makeScale(t,e,n){return this.set(t,0,0,0,0,e,0,0,0,0,n,0,0,0,0,1),this}makeShear(t,e,n,r,a,o){return this.set(1,n,a,0,t,1,o,0,e,r,1,0,0,0,0,1),this}compose(t,e,n){const r=this.elements,a=e._x,o=e._y,s=e._z,l=e._w,c=a+a,u=o+o,d=s+s,f=a*c,m=a*u,v=a*d,_=o*u,p=o*d,h=s*d,E=l*c,T=l*u,b=l*d,D=n.x,R=n.y,w=n.z;return r[0]=(1-(_+h))*D,r[1]=(m+b)*D,r[2]=(v-T)*D,r[3]=0,r[4]=(m-b)*R,r[5]=(1-(f+h))*R,r[6]=(p+E)*R,r[7]=0,r[8]=(v+T)*w,r[9]=(p-E)*w,r[10]=(1-(f+_))*w,r[11]=0,r[12]=t.x,r[13]=t.y,r[14]=t.z,r[15]=1,this}decompose(t,e,n){const r=this.elements;let a=Ln.set(r[0],r[1],r[2]).length();const o=Ln.set(r[4],r[5],r[6]).length(),s=Ln.set(r[8],r[9],r[10]).length();this.determinant()<0&&(a=-a),t.x=r[12],t.y=r[13],t.z=r[14],De.copy(this);const c=1/a,u=1/o,d=1/s;return De.elements[0]*=c,De.elements[1]*=c,De.elements[2]*=c,De.elements[4]*=u,De.elements[5]*=u,De.elements[6]*=u,De.elements[8]*=d,De.elements[9]*=d,De.elements[10]*=d,e.setFromRotationMatrix(De),n.x=a,n.y=o,n.z=s,this}makePerspective(t,e,n,r,a,o,s=je){const l=this.elements,c=2*a/(e-t),u=2*a/(n-r),d=(e+t)/(e-t),f=(n+r)/(n-r);let m,v;if(s===je)m=-(o+a)/(o-a),v=-2*o*a/(o-a);else if(s===Wi)m=-o/(o-a),v=-o*a/(o-a);else throw new Error("THREE.Matrix4.makePerspective(): Invalid coordinate system: "+s);return l[0]=c,l[4]=0,l[8]=d,l[12]=0,l[1]=0,l[5]=u,l[9]=f,l[13]=0,l[2]=0,l[6]=0,l[10]=m,l[14]=v,l[3]=0,l[7]=0,l[11]=-1,l[15]=0,this}makeOrthographic(t,e,n,r,a,o,s=je){const l=this.elements,c=1/(e-t),u=1/(n-r),d=1/(o-a),f=(e+t)*c,m=(n+r)*u;let v,_;if(s===je)v=(o+a)*d,_=-2*d;else if(s===Wi)v=a*d,_=-1*d;else throw new Error("THREE.Matrix4.makeOrthographic(): Invalid coordinate system: "+s);return l[0]=2*c,l[4]=0,l[8]=0,l[12]=-f,l[1]=0,l[5]=2*u,l[9]=0,l[13]=-m,l[2]=0,l[6]=0,l[10]=_,l[14]=-v,l[3]=0,l[7]=0,l[11]=0,l[15]=1,this}equals(t){const e=this.elements,n=t.elements;for(let r=0;r<16;r++)if(e[r]!==n[r])return!1;return!0}fromArray(t,e=0){for(let n=0;n<16;n++)this.elements[n]=t[n+e];return this}toArray(t=[],e=0){const n=this.elements;return t[e]=n[0],t[e+1]=n[1],t[e+2]=n[2],t[e+3]=n[3],t[e+4]=n[4],t[e+5]=n[5],t[e+6]=n[6],t[e+7]=n[7],t[e+8]=n[8],t[e+9]=n[9],t[e+10]=n[10],t[e+11]=n[11],t[e+12]=n[12],t[e+13]=n[13],t[e+14]=n[14],t[e+15]=n[15],t}}const Ln=new L,De=new Kt,Rl=new L(0,0,0),Cl=new L(1,1,1),rn=new L,Ti=new L,Te=new L,qa=new Kt,Ya=new hi;class $i{constructor(t=0,e=0,n=0,r=$i.DEFAULT_ORDER){this.isEuler=!0,this._x=t,this._y=e,this._z=n,this._order=r}get x(){return this._x}set x(t){this._x=t,this._onChangeCallback()}get y(){return this._y}set y(t){this._y=t,this._onChangeCallback()}get z(){return this._z}set z(t){this._z=t,this._onChangeCallback()}get order(){return this._order}set order(t){this._order=t,this._onChangeCallback()}set(t,e,n,r=this._order){return this._x=t,this._y=e,this._z=n,this._order=r,this._onChangeCallback(),this}clone(){return new this.constructor(this._x,this._y,this._z,this._order)}copy(t){return this._x=t._x,this._y=t._y,this._z=t._z,this._order=t._order,this._onChangeCallback(),this}setFromRotationMatrix(t,e=this._order,n=!0){const r=t.elements,a=r[0],o=r[4],s=r[8],l=r[1],c=r[5],u=r[9],d=r[2],f=r[6],m=r[10];switch(e){case"XYZ":this._y=Math.asin(ve(s,-1,1)),Math.abs(s)<.9999999?(this._x=Math.atan2(-u,m),this._z=Math.atan2(-o,a)):(this._x=Math.atan2(f,c),this._z=0);break;case"YXZ":this._x=Math.asin(-ve(u,-1,1)),Math.abs(u)<.9999999?(this._y=Math.atan2(s,m),this._z=Math.atan2(l,c)):(this._y=Math.atan2(-d,a),this._z=0);break;case"ZXY":this._x=Math.asin(ve(f,-1,1)),Math.abs(f)<.9999999?(this._y=Math.atan2(-d,m),this._z=Math.atan2(-o,c)):(this._y=0,this._z=Math.atan2(l,a));break;case"ZYX":this._y=Math.asin(-ve(d,-1,1)),Math.abs(d)<.9999999?(this._x=Math.atan2(f,m),this._z=Math.atan2(l,a)):(this._x=0,this._z=Math.atan2(-o,c));break;case"YZX":this._z=Math.asin(ve(l,-1,1)),Math.abs(l)<.9999999?(this._x=Math.atan2(-u,c),this._y=Math.atan2(-d,a)):(this._x=0,this._y=Math.atan2(s,m));break;case"XZY":this._z=Math.asin(-ve(o,-1,1)),Math.abs(o)<.9999999?(this._x=Math.atan2(f,c),this._y=Math.atan2(s,a)):(this._x=Math.atan2(-u,m),this._y=0);break;default:console.warn("THREE.Euler: .setFromRotationMatrix() encountered an unknown order: "+e)}return this._order=e,n===!0&&this._onChangeCallback(),this}setFromQuaternion(t,e,n){return qa.makeRotationFromQuaternion(t),this.setFromRotationMatrix(qa,e,n)}setFromVector3(t,e=this._order){return this.set(t.x,t.y,t.z,e)}reorder(t){return Ya.setFromEuler(this),this.setFromQuaternion(Ya,t)}equals(t){return t._x===this._x&&t._y===this._y&&t._z===this._z&&t._order===this._order}fromArray(t){return this._x=t[0],this._y=t[1],this._z=t[2],t[3]!==void 0&&(this._order=t[3]),this._onChangeCallback(),this}toArray(t=[],e=0){return t[e]=this._x,t[e+1]=this._y,t[e+2]=this._z,t[e+3]=this._order,t}_onChange(t){return this._onChangeCallback=t,this}_onChangeCallback(){}*[Symbol.iterator](){yield this._x,yield this._y,yield this._z,yield this._order}}$i.DEFAULT_ORDER="XYZ";class Xs{constructor(){this.mask=1}set(t){this.mask=(1<<t|0)>>>0}enable(t){this.mask|=1<<t|0}enableAll(){this.mask=-1}toggle(t){this.mask^=1<<t|0}disable(t){this.mask&=~(1<<t|0)}disableAll(){this.mask=0}test(t){return(this.mask&t.mask)!==0}isEnabled(t){return(this.mask&(1<<t|0))!==0}}let Pl=0;const $a=new L,Dn=new hi,ke=new Kt,Mi=new L,ni=new L,Ll=new L,Dl=new hi,ja=new L(1,0,0),Za=new L(0,1,0),Ka=new L(0,0,1),Ul={type:"added"},Il={type:"removed"};class be extends Zn{constructor(){super(),this.isObject3D=!0,Object.defineProperty(this,"id",{value:Pl++}),this.uuid=ui(),this.name="",this.type="Object3D",this.parent=null,this.children=[],this.up=be.DEFAULT_UP.clone();const t=new L,e=new $i,n=new hi,r=new L(1,1,1);function a(){n.setFromEuler(e,!1)}function o(){e.setFromQuaternion(n,void 0,!1)}e._onChange(a),n._onChange(o),Object.defineProperties(this,{position:{configurable:!0,enumerable:!0,value:t},rotation:{configurable:!0,enumerable:!0,value:e},quaternion:{configurable:!0,enumerable:!0,value:n},scale:{configurable:!0,enumerable:!0,value:r},modelViewMatrix:{value:new Kt},normalMatrix:{value:new Ct}}),this.matrix=new Kt,this.matrixWorld=new Kt,this.matrixAutoUpdate=be.DEFAULT_MATRIX_AUTO_UPDATE,this.matrixWorldAutoUpdate=be.DEFAULT_MATRIX_WORLD_AUTO_UPDATE,this.matrixWorldNeedsUpdate=!1,this.layers=new Xs,this.visible=!0,this.castShadow=!1,this.receiveShadow=!1,this.frustumCulled=!0,this.renderOrder=0,this.animations=[],this.userData={}}onBeforeShadow(){}onAfterShadow(){}onBeforeRender(){}onAfterRender(){}applyMatrix4(t){this.matrixAutoUpdate&&this.updateMatrix(),this.matrix.premultiply(t),this.matrix.decompose(this.position,this.quaternion,this.scale)}applyQuaternion(t){return this.quaternion.premultiply(t),this}setRotationFromAxisAngle(t,e){this.quaternion.setFromAxisAngle(t,e)}setRotationFromEuler(t){this.quaternion.setFromEuler(t,!0)}setRotationFromMatrix(t){this.quaternion.setFromRotationMatrix(t)}setRotationFromQuaternion(t){this.quaternion.copy(t)}rotateOnAxis(t,e){return Dn.setFromAxisAngle(t,e),this.quaternion.multiply(Dn),this}rotateOnWorldAxis(t,e){return Dn.setFromAxisAngle(t,e),this.quaternion.premultiply(Dn),this}rotateX(t){return this.rotateOnAxis(ja,t)}rotateY(t){return this.rotateOnAxis(Za,t)}rotateZ(t){return this.rotateOnAxis(Ka,t)}translateOnAxis(t,e){return $a.copy(t).applyQuaternion(this.quaternion),this.position.add($a.multiplyScalar(e)),this}translateX(t){return this.translateOnAxis(ja,t)}translateY(t){return this.translateOnAxis(Za,t)}translateZ(t){return this.translateOnAxis(Ka,t)}localToWorld(t){return this.updateWorldMatrix(!0,!1),t.applyMatrix4(this.matrixWorld)}worldToLocal(t){return this.updateWorldMatrix(!0,!1),t.applyMatrix4(ke.copy(this.matrixWorld).invert())}lookAt(t,e,n){t.isVector3?Mi.copy(t):Mi.set(t,e,n);const r=this.parent;this.updateWorldMatrix(!0,!1),ni.setFromMatrixPosition(this.matrixWorld),this.isCamera||this.isLight?ke.lookAt(ni,Mi,this.up):ke.lookAt(Mi,ni,this.up),this.quaternion.setFromRotationMatrix(ke),r&&(ke.extractRotation(r.matrixWorld),Dn.setFromRotationMatrix(ke),this.quaternion.premultiply(Dn.invert()))}add(t){if(arguments.length>1){for(let e=0;e<arguments.length;e++)this.add(arguments[e]);return this}return t===this?(console.error("THREE.Object3D.add: object can't be added as a child of itself.",t),this):(t&&t.isObject3D?(t.parent!==null&&t.parent.remove(t),t.parent=this,this.children.push(t),t.dispatchEvent(Ul)):console.error("THREE.Object3D.add: object not an instance of THREE.Object3D.",t),this)}remove(t){if(arguments.length>1){for(let n=0;n<arguments.length;n++)this.remove(arguments[n]);return this}const e=this.children.indexOf(t);return e!==-1&&(t.parent=null,this.children.splice(e,1),t.dispatchEvent(Il)),this}removeFromParent(){const t=this.parent;return t!==null&&t.remove(this),this}clear(){return this.remove(...this.children)}attach(t){return this.updateWorldMatrix(!0,!1),ke.copy(this.matrixWorld).invert(),t.parent!==null&&(t.parent.updateWorldMatrix(!0,!1),ke.multiply(t.parent.matrixWorld)),t.applyMatrix4(ke),this.add(t),t.updateWorldMatrix(!1,!0),this}getObjectById(t){return this.getObjectByProperty("id",t)}getObjectByName(t){return this.getObjectByProperty("name",t)}getObjectByProperty(t,e){if(this[t]===e)return this;for(let n=0,r=this.children.length;n<r;n++){const o=this.children[n].getObjectByProperty(t,e);if(o!==void 0)return o}}getObjectsByProperty(t,e,n=[]){this[t]===e&&n.push(this);const r=this.children;for(let a=0,o=r.length;a<o;a++)r[a].getObjectsByProperty(t,e,n);return n}getWorldPosition(t){return this.updateWorldMatrix(!0,!1),t.setFromMatrixPosition(this.matrixWorld)}getWorldQuaternion(t){return this.updateWorldMatrix(!0,!1),this.matrixWorld.decompose(ni,t,Ll),t}getWorldScale(t){return this.updateWorldMatrix(!0,!1),this.matrixWorld.decompose(ni,Dl,t),t}getWorldDirection(t){this.updateWorldMatrix(!0,!1);const e=this.matrixWorld.elements;return t.set(e[8],e[9],e[10]).normalize()}raycast(){}traverse(t){t(this);const e=this.children;for(let n=0,r=e.length;n<r;n++)e[n].traverse(t)}traverseVisible(t){if(this.visible===!1)return;t(this);const e=this.children;for(let n=0,r=e.length;n<r;n++)e[n].traverseVisible(t)}traverseAncestors(t){const e=this.parent;e!==null&&(t(e),e.traverseAncestors(t))}updateMatrix(){this.matrix.compose(this.position,this.quaternion,this.scale),this.matrixWorldNeedsUpdate=!0}updateMatrixWorld(t){this.matrixAutoUpdate&&this.updateMatrix(),(this.matrixWorldNeedsUpdate||t)&&(this.parent===null?this.matrixWorld.copy(this.matrix):this.matrixWorld.multiplyMatrices(this.parent.matrixWorld,this.matrix),this.matrixWorldNeedsUpdate=!1,t=!0);const e=this.children;for(let n=0,r=e.length;n<r;n++){const a=e[n];(a.matrixWorldAutoUpdate===!0||t===!0)&&a.updateMatrixWorld(t)}}updateWorldMatrix(t,e){const n=this.parent;if(t===!0&&n!==null&&n.matrixWorldAutoUpdate===!0&&n.updateWorldMatrix(!0,!1),this.matrixAutoUpdate&&this.updateMatrix(),this.parent===null?this.matrixWorld.copy(this.matrix):this.matrixWorld.multiplyMatrices(this.parent.matrixWorld,this.matrix),e===!0){const r=this.children;for(let a=0,o=r.length;a<o;a++){const s=r[a];s.matrixWorldAutoUpdate===!0&&s.updateWorldMatrix(!1,!0)}}}toJSON(t){const e=t===void 0||typeof t=="string",n={};e&&(t={geometries:{},materials:{},textures:{},images:{},shapes:{},skeletons:{},animations:{},nodes:{}},n.metadata={version:4.6,type:"Object",generator:"Object3D.toJSON"});const r={};r.uuid=this.uuid,r.type=this.type,this.name!==""&&(r.name=this.name),this.castShadow===!0&&(r.castShadow=!0),this.receiveShadow===!0&&(r.receiveShadow=!0),this.visible===!1&&(r.visible=!1),this.frustumCulled===!1&&(r.frustumCulled=!1),this.renderOrder!==0&&(r.renderOrder=this.renderOrder),Object.keys(this.userData).length>0&&(r.userData=this.userData),r.layers=this.layers.mask,r.matrix=this.matrix.toArray(),r.up=this.up.toArray(),this.matrixAutoUpdate===!1&&(r.matrixAutoUpdate=!1),this.isInstancedMesh&&(r.type="InstancedMesh",r.count=this.count,r.instanceMatrix=this.instanceMatrix.toJSON(),this.instanceColor!==null&&(r.instanceColor=this.instanceColor.toJSON())),this.isBatchedMesh&&(r.type="BatchedMesh",r.perObjectFrustumCulled=this.perObjectFrustumCulled,r.sortObjects=this.sortObjects,r.drawRanges=this._drawRanges,r.reservedRanges=this._reservedRanges,r.visibility=this._visibility,r.active=this._active,r.bounds=this._bounds.map(s=>({boxInitialized:s.boxInitialized,boxMin:s.box.min.toArray(),boxMax:s.box.max.toArray(),sphereInitialized:s.sphereInitialized,sphereRadius:s.sphere.radius,sphereCenter:s.sphere.center.toArray()})),r.maxGeometryCount=this._maxGeometryCount,r.maxVertexCount=this._maxVertexCount,r.maxIndexCount=this._maxIndexCount,r.geometryInitialized=this._geometryInitialized,r.geometryCount=this._geometryCount,r.matricesTexture=this._matricesTexture.toJSON(t),this.boundingSphere!==null&&(r.boundingSphere={center:r.boundingSphere.center.toArray(),radius:r.boundingSphere.radius}),this.boundingBox!==null&&(r.boundingBox={min:r.boundingBox.min.toArray(),max:r.boundingBox.max.toArray()}));function a(s,l){return s[l.uuid]===void 0&&(s[l.uuid]=l.toJSON(t)),l.uuid}if(this.isScene)this.background&&(this.background.isColor?r.background=this.background.toJSON():this.background.isTexture&&(r.background=this.background.toJSON(t).uuid)),this.environment&&this.environment.isTexture&&this.environment.isRenderTargetTexture!==!0&&(r.environment=this.environment.toJSON(t).uuid);else if(this.isMesh||this.isLine||this.isPoints){r.geometry=a(t.geometries,this.geometry);const s=this.geometry.parameters;if(s!==void 0&&s.shapes!==void 0){const l=s.shapes;if(Array.isArray(l))for(let c=0,u=l.length;c<u;c++){const d=l[c];a(t.shapes,d)}else a(t.shapes,l)}}if(this.isSkinnedMesh&&(r.bindMode=this.bindMode,r.bindMatrix=this.bindMatrix.toArray(),this.skeleton!==void 0&&(a(t.skeletons,this.skeleton),r.skeleton=this.skeleton.uuid)),this.material!==void 0)if(Array.isArray(this.material)){const s=[];for(let l=0,c=this.material.length;l<c;l++)s.push(a(t.materials,this.material[l]));r.material=s}else r.material=a(t.materials,this.material);if(this.children.length>0){r.children=[];for(let s=0;s<this.children.length;s++)r.children.push(this.children[s].toJSON(t).object)}if(this.animations.length>0){r.animations=[];for(let s=0;s<this.animations.length;s++){const l=this.animations[s];r.animations.push(a(t.animations,l))}}if(e){const s=o(t.geometries),l=o(t.materials),c=o(t.textures),u=o(t.images),d=o(t.shapes),f=o(t.skeletons),m=o(t.animations),v=o(t.nodes);s.length>0&&(n.geometries=s),l.length>0&&(n.materials=l),c.length>0&&(n.textures=c),u.length>0&&(n.images=u),d.length>0&&(n.shapes=d),f.length>0&&(n.skeletons=f),m.length>0&&(n.animations=m),v.length>0&&(n.nodes=v)}return n.object=r,n;function o(s){const l=[];for(const c in s){const u=s[c];delete u.metadata,l.push(u)}return l}}clone(t){return new this.constructor().copy(this,t)}copy(t,e=!0){if(this.name=t.name,this.up.copy(t.up),this.position.copy(t.position),this.rotation.order=t.rotation.order,this.quaternion.copy(t.quaternion),this.scale.copy(t.scale),this.matrix.copy(t.matrix),this.matrixWorld.copy(t.matrixWorld),this.matrixAutoUpdate=t.matrixAutoUpdate,this.matrixWorldAutoUpdate=t.matrixWorldAutoUpdate,this.matrixWorldNeedsUpdate=t.matrixWorldNeedsUpdate,this.layers.mask=t.layers.mask,this.visible=t.visible,this.castShadow=t.castShadow,this.receiveShadow=t.receiveShadow,this.frustumCulled=t.frustumCulled,this.renderOrder=t.renderOrder,this.animations=t.animations.slice(),this.userData=JSON.parse(JSON.stringify(t.userData)),e===!0)for(let n=0;n<t.children.length;n++){const r=t.children[n];this.add(r.clone())}return this}}be.DEFAULT_UP=new L(0,1,0);be.DEFAULT_MATRIX_AUTO_UPDATE=!0;be.DEFAULT_MATRIX_WORLD_AUTO_UPDATE=!0;const Ue=new L,We=new L,vr=new L,Xe=new L,Un=new L,In=new L,Ja=new L,xr=new L,Sr=new L,yr=new L;let Ei=!1;class Ie{constructor(t=new L,e=new L,n=new L){this.a=t,this.b=e,this.c=n}static getNormal(t,e,n,r){r.subVectors(n,e),Ue.subVectors(t,e),r.cross(Ue);const a=r.lengthSq();return a>0?r.multiplyScalar(1/Math.sqrt(a)):r.set(0,0,0)}static getBarycoord(t,e,n,r,a){Ue.subVectors(r,e),We.subVectors(n,e),vr.subVectors(t,e);const o=Ue.dot(Ue),s=Ue.dot(We),l=Ue.dot(vr),c=We.dot(We),u=We.dot(vr),d=o*c-s*s;if(d===0)return a.set(0,0,0),null;const f=1/d,m=(c*l-s*u)*f,v=(o*u-s*l)*f;return a.set(1-m-v,v,m)}static containsPoint(t,e,n,r){return this.getBarycoord(t,e,n,r,Xe)===null?!1:Xe.x>=0&&Xe.y>=0&&Xe.x+Xe.y<=1}static getUV(t,e,n,r,a,o,s,l){return Ei===!1&&(console.warn("THREE.Triangle.getUV() has been renamed to THREE.Triangle.getInterpolation()."),Ei=!0),this.getInterpolation(t,e,n,r,a,o,s,l)}static getInterpolation(t,e,n,r,a,o,s,l){return this.getBarycoord(t,e,n,r,Xe)===null?(l.x=0,l.y=0,"z"in l&&(l.z=0),"w"in l&&(l.w=0),null):(l.setScalar(0),l.addScaledVector(a,Xe.x),l.addScaledVector(o,Xe.y),l.addScaledVector(s,Xe.z),l)}static isFrontFacing(t,e,n,r){return Ue.subVectors(n,e),We.subVectors(t,e),Ue.cross(We).dot(r)<0}set(t,e,n){return this.a.copy(t),this.b.copy(e),this.c.copy(n),this}setFromPointsAndIndices(t,e,n,r){return this.a.copy(t[e]),this.b.copy(t[n]),this.c.copy(t[r]),this}setFromAttributeAndIndices(t,e,n,r){return this.a.fromBufferAttribute(t,e),this.b.fromBufferAttribute(t,n),this.c.fromBufferAttribute(t,r),this}clone(){return new this.constructor().copy(this)}copy(t){return this.a.copy(t.a),this.b.copy(t.b),this.c.copy(t.c),this}getArea(){return Ue.subVectors(this.c,this.b),We.subVectors(this.a,this.b),Ue.cross(We).length()*.5}getMidpoint(t){return t.addVectors(this.a,this.b).add(this.c).multiplyScalar(1/3)}getNormal(t){return Ie.getNormal(this.a,this.b,this.c,t)}getPlane(t){return t.setFromCoplanarPoints(this.a,this.b,this.c)}getBarycoord(t,e){return Ie.getBarycoord(t,this.a,this.b,this.c,e)}getUV(t,e,n,r,a){return Ei===!1&&(console.warn("THREE.Triangle.getUV() has been renamed to THREE.Triangle.getInterpolation()."),Ei=!0),Ie.getInterpolation(t,this.a,this.b,this.c,e,n,r,a)}getInterpolation(t,e,n,r,a){return Ie.getInterpolation(t,this.a,this.b,this.c,e,n,r,a)}containsPoint(t){return Ie.containsPoint(t,this.a,this.b,this.c)}isFrontFacing(t){return Ie.isFrontFacing(this.a,this.b,this.c,t)}intersectsBox(t){return t.intersectsTriangle(this)}closestPointToPoint(t,e){const n=this.a,r=this.b,a=this.c;let o,s;Un.subVectors(r,n),In.subVectors(a,n),xr.subVectors(t,n);const l=Un.dot(xr),c=In.dot(xr);if(l<=0&&c<=0)return e.copy(n);Sr.subVectors(t,r);const u=Un.dot(Sr),d=In.dot(Sr);if(u>=0&&d<=u)return e.copy(r);const f=l*d-u*c;if(f<=0&&l>=0&&u<=0)return o=l/(l-u),e.copy(n).addScaledVector(Un,o);yr.subVectors(t,a);const m=Un.dot(yr),v=In.dot(yr);if(v>=0&&m<=v)return e.copy(a);const _=m*c-l*v;if(_<=0&&c>=0&&v<=0)return s=c/(c-v),e.copy(n).addScaledVector(In,s);const p=u*v-m*d;if(p<=0&&d-u>=0&&m-v>=0)return Ja.subVectors(a,r),s=(d-u)/(d-u+(m-v)),e.copy(r).addScaledVector(Ja,s);const h=1/(p+_+f);return o=_*h,s=f*h,e.copy(n).addScaledVector(Un,o).addScaledVector(In,s)}equals(t){return t.a.equals(this.a)&&t.b.equals(this.b)&&t.c.equals(this.c)}}const qs={aliceblue:15792383,antiquewhite:16444375,aqua:65535,aquamarine:8388564,azure:15794175,beige:16119260,bisque:16770244,black:0,blanchedalmond:16772045,blue:255,blueviolet:9055202,brown:10824234,burlywood:14596231,cadetblue:6266528,chartreuse:8388352,chocolate:13789470,coral:16744272,cornflowerblue:6591981,cornsilk:16775388,crimson:14423100,cyan:65535,darkblue:139,darkcyan:35723,darkgoldenrod:12092939,darkgray:11119017,darkgreen:25600,darkgrey:11119017,darkkhaki:12433259,darkmagenta:9109643,darkolivegreen:5597999,darkorange:16747520,darkorchid:10040012,darkred:9109504,darksalmon:15308410,darkseagreen:9419919,darkslateblue:4734347,darkslategray:3100495,darkslategrey:3100495,darkturquoise:52945,darkviolet:9699539,deeppink:16716947,deepskyblue:49151,dimgray:6908265,dimgrey:6908265,dodgerblue:2003199,firebrick:11674146,floralwhite:16775920,forestgreen:2263842,fuchsia:16711935,gainsboro:14474460,ghostwhite:16316671,gold:16766720,goldenrod:14329120,gray:8421504,green:32768,greenyellow:11403055,grey:8421504,honeydew:15794160,hotpink:16738740,indianred:13458524,indigo:4915330,ivory:16777200,khaki:15787660,lavender:15132410,lavenderblush:16773365,lawngreen:8190976,lemonchiffon:16775885,lightblue:11393254,lightcoral:15761536,lightcyan:14745599,lightgoldenrodyellow:16448210,lightgray:13882323,lightgreen:9498256,lightgrey:13882323,lightpink:16758465,lightsalmon:16752762,lightseagreen:2142890,lightskyblue:8900346,lightslategray:7833753,lightslategrey:7833753,lightsteelblue:11584734,lightyellow:16777184,lime:65280,limegreen:3329330,linen:16445670,magenta:16711935,maroon:8388608,mediumaquamarine:6737322,mediumblue:205,mediumorchid:12211667,mediumpurple:9662683,mediumseagreen:3978097,mediumslateblue:8087790,mediumspringgreen:64154,mediumturquoise:4772300,mediumvioletred:13047173,midnightblue:1644912,mintcream:16121850,mistyrose:16770273,moccasin:16770229,navajowhite:16768685,navy:128,oldlace:16643558,olive:8421376,olivedrab:7048739,orange:16753920,orangered:16729344,orchid:14315734,palegoldenrod:15657130,palegreen:10025880,paleturquoise:11529966,palevioletred:14381203,papayawhip:16773077,peachpuff:16767673,peru:13468991,pink:16761035,plum:14524637,powderblue:11591910,purple:8388736,rebeccapurple:6697881,red:16711680,rosybrown:12357519,royalblue:4286945,saddlebrown:9127187,salmon:16416882,sandybrown:16032864,seagreen:3050327,seashell:16774638,sienna:10506797,silver:12632256,skyblue:8900331,slateblue:6970061,slategray:7372944,slategrey:7372944,snow:16775930,springgreen:65407,steelblue:4620980,tan:13808780,teal:32896,thistle:14204888,tomato:16737095,turquoise:4251856,violet:15631086,wheat:16113331,white:16777215,whitesmoke:16119285,yellow:16776960,yellowgreen:10145074},an={h:0,s:0,l:0},bi={h:0,s:0,l:0};function Tr(i,t,e){return e<0&&(e+=1),e>1&&(e-=1),e<1/6?i+(t-i)*6*e:e<1/2?t:e<2/3?i+(t-i)*6*(2/3-e):i}class kt{constructor(t,e,n){return this.isColor=!0,this.r=1,this.g=1,this.b=1,this.set(t,e,n)}set(t,e,n){if(e===void 0&&n===void 0){const r=t;r&&r.isColor?this.copy(r):typeof r=="number"?this.setHex(r):typeof r=="string"&&this.setStyle(r)}else this.setRGB(t,e,n);return this}setScalar(t){return this.r=t,this.g=t,this.b=t,this}setHex(t,e=le){return t=Math.floor(t),this.r=(t>>16&255)/255,this.g=(t>>8&255)/255,this.b=(t&255)/255,Gt.toWorkingColorSpace(this,e),this}setRGB(t,e,n,r=Gt.workingColorSpace){return this.r=t,this.g=e,this.b=n,Gt.toWorkingColorSpace(this,r),this}setHSL(t,e,n,r=Gt.workingColorSpace){if(t=xl(t,1),e=ve(e,0,1),n=ve(n,0,1),e===0)this.r=this.g=this.b=n;else{const a=n<=.5?n*(1+e):n+e-n*e,o=2*n-a;this.r=Tr(o,a,t+1/3),this.g=Tr(o,a,t),this.b=Tr(o,a,t-1/3)}return Gt.toWorkingColorSpace(this,r),this}setStyle(t,e=le){function n(a){a!==void 0&&parseFloat(a)<1&&console.warn("THREE.Color: Alpha component of "+t+" will be ignored.")}let r;if(r=/^(\w+)\(([^\)]*)\)/.exec(t)){let a;const o=r[1],s=r[2];switch(o){case"rgb":case"rgba":if(a=/^\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(s))return n(a[4]),this.setRGB(Math.min(255,parseInt(a[1],10))/255,Math.min(255,parseInt(a[2],10))/255,Math.min(255,parseInt(a[3],10))/255,e);if(a=/^\s*(\d+)\%\s*,\s*(\d+)\%\s*,\s*(\d+)\%\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(s))return n(a[4]),this.setRGB(Math.min(100,parseInt(a[1],10))/100,Math.min(100,parseInt(a[2],10))/100,Math.min(100,parseInt(a[3],10))/100,e);break;case"hsl":case"hsla":if(a=/^\s*(\d*\.?\d+)\s*,\s*(\d*\.?\d+)\%\s*,\s*(\d*\.?\d+)\%\s*(?:,\s*(\d*\.?\d+)\s*)?$/.exec(s))return n(a[4]),this.setHSL(parseFloat(a[1])/360,parseFloat(a[2])/100,parseFloat(a[3])/100,e);break;default:console.warn("THREE.Color: Unknown color model "+t)}}else if(r=/^\#([A-Fa-f\d]+)$/.exec(t)){const a=r[1],o=a.length;if(o===3)return this.setRGB(parseInt(a.charAt(0),16)/15,parseInt(a.charAt(1),16)/15,parseInt(a.charAt(2),16)/15,e);if(o===6)return this.setHex(parseInt(a,16),e);console.warn("THREE.Color: Invalid hex color "+t)}else if(t&&t.length>0)return this.setColorName(t,e);return this}setColorName(t,e=le){const n=qs[t.toLowerCase()];return n!==void 0?this.setHex(n,e):console.warn("THREE.Color: Unknown color "+t),this}clone(){return new this.constructor(this.r,this.g,this.b)}copy(t){return this.r=t.r,this.g=t.g,this.b=t.b,this}copySRGBToLinear(t){return this.r=Xn(t.r),this.g=Xn(t.g),this.b=Xn(t.b),this}copyLinearToSRGB(t){return this.r=ur(t.r),this.g=ur(t.g),this.b=ur(t.b),this}convertSRGBToLinear(){return this.copySRGBToLinear(this),this}convertLinearToSRGB(){return this.copyLinearToSRGB(this),this}getHex(t=le){return Gt.fromWorkingColorSpace(de.copy(this),t),Math.round(ve(de.r*255,0,255))*65536+Math.round(ve(de.g*255,0,255))*256+Math.round(ve(de.b*255,0,255))}getHexString(t=le){return("000000"+this.getHex(t).toString(16)).slice(-6)}getHSL(t,e=Gt.workingColorSpace){Gt.fromWorkingColorSpace(de.copy(this),e);const n=de.r,r=de.g,a=de.b,o=Math.max(n,r,a),s=Math.min(n,r,a);let l,c;const u=(s+o)/2;if(s===o)l=0,c=0;else{const d=o-s;switch(c=u<=.5?d/(o+s):d/(2-o-s),o){case n:l=(r-a)/d+(r<a?6:0);break;case r:l=(a-n)/d+2;break;case a:l=(n-r)/d+4;break}l/=6}return t.h=l,t.s=c,t.l=u,t}getRGB(t,e=Gt.workingColorSpace){return Gt.fromWorkingColorSpace(de.copy(this),e),t.r=de.r,t.g=de.g,t.b=de.b,t}getStyle(t=le){Gt.fromWorkingColorSpace(de.copy(this),t);const e=de.r,n=de.g,r=de.b;return t!==le?`color(${t} ${e.toFixed(3)} ${n.toFixed(3)} ${r.toFixed(3)})`:`rgb(${Math.round(e*255)},${Math.round(n*255)},${Math.round(r*255)})`}offsetHSL(t,e,n){return this.getHSL(an),this.setHSL(an.h+t,an.s+e,an.l+n)}add(t){return this.r+=t.r,this.g+=t.g,this.b+=t.b,this}addColors(t,e){return this.r=t.r+e.r,this.g=t.g+e.g,this.b=t.b+e.b,this}addScalar(t){return this.r+=t,this.g+=t,this.b+=t,this}sub(t){return this.r=Math.max(0,this.r-t.r),this.g=Math.max(0,this.g-t.g),this.b=Math.max(0,this.b-t.b),this}multiply(t){return this.r*=t.r,this.g*=t.g,this.b*=t.b,this}multiplyScalar(t){return this.r*=t,this.g*=t,this.b*=t,this}lerp(t,e){return this.r+=(t.r-this.r)*e,this.g+=(t.g-this.g)*e,this.b+=(t.b-this.b)*e,this}lerpColors(t,e,n){return this.r=t.r+(e.r-t.r)*n,this.g=t.g+(e.g-t.g)*n,this.b=t.b+(e.b-t.b)*n,this}lerpHSL(t,e){this.getHSL(an),t.getHSL(bi);const n=lr(an.h,bi.h,e),r=lr(an.s,bi.s,e),a=lr(an.l,bi.l,e);return this.setHSL(n,r,a),this}setFromVector3(t){return this.r=t.x,this.g=t.y,this.b=t.z,this}applyMatrix3(t){const e=this.r,n=this.g,r=this.b,a=t.elements;return this.r=a[0]*e+a[3]*n+a[6]*r,this.g=a[1]*e+a[4]*n+a[7]*r,this.b=a[2]*e+a[5]*n+a[8]*r,this}equals(t){return t.r===this.r&&t.g===this.g&&t.b===this.b}fromArray(t,e=0){return this.r=t[e],this.g=t[e+1],this.b=t[e+2],this}toArray(t=[],e=0){return t[e]=this.r,t[e+1]=this.g,t[e+2]=this.b,t}fromBufferAttribute(t,e){return this.r=t.getX(e),this.g=t.getY(e),this.b=t.getZ(e),this}toJSON(){return this.getHex()}*[Symbol.iterator](){yield this.r,yield this.g,yield this.b}}const de=new kt;kt.NAMES=qs;let Nl=0;class ji extends Zn{constructor(){super(),this.isMaterial=!0,Object.defineProperty(this,"id",{value:Nl++}),this.uuid=ui(),this.name="",this.type="Material",this.blending=Wn,this.side=un,this.vertexColors=!1,this.opacity=1,this.transparent=!1,this.alphaHash=!1,this.blendSrc=Ir,this.blendDst=Nr,this.blendEquation=yn,this.blendSrcAlpha=null,this.blendDstAlpha=null,this.blendEquationAlpha=null,this.blendColor=new kt(0,0,0),this.blendAlpha=0,this.depthFunc=Vi,this.depthTest=!0,this.depthWrite=!0,this.stencilWriteMask=255,this.stencilFunc=za,this.stencilRef=0,this.stencilFuncMask=255,this.stencilFail=An,this.stencilZFail=An,this.stencilZPass=An,this.stencilWrite=!1,this.clippingPlanes=null,this.clipIntersection=!1,this.clipShadows=!1,this.shadowSide=null,this.colorWrite=!0,this.precision=null,this.polygonOffset=!1,this.polygonOffsetFactor=0,this.polygonOffsetUnits=0,this.dithering=!1,this.alphaToCoverage=!1,this.premultipliedAlpha=!1,this.forceSinglePass=!1,this.visible=!0,this.toneMapped=!0,this.userData={},this.version=0,this._alphaTest=0}get alphaTest(){return this._alphaTest}set alphaTest(t){this._alphaTest>0!=t>0&&this.version++,this._alphaTest=t}onBuild(){}onBeforeRender(){}onBeforeCompile(){}customProgramCacheKey(){return this.onBeforeCompile.toString()}setValues(t){if(t!==void 0)for(const e in t){const n=t[e];if(n===void 0){console.warn(`THREE.Material: parameter '${e}' has value of undefined.`);continue}const r=this[e];if(r===void 0){console.warn(`THREE.Material: '${e}' is not a property of THREE.${this.type}.`);continue}r&&r.isColor?r.set(n):r&&r.isVector3&&n&&n.isVector3?r.copy(n):this[e]=n}}toJSON(t){const e=t===void 0||typeof t=="string";e&&(t={textures:{},images:{}});const n={metadata:{version:4.6,type:"Material",generator:"Material.toJSON"}};n.uuid=this.uuid,n.type=this.type,this.name!==""&&(n.name=this.name),this.color&&this.color.isColor&&(n.color=this.color.getHex()),this.roughness!==void 0&&(n.roughness=this.roughness),this.metalness!==void 0&&(n.metalness=this.metalness),this.sheen!==void 0&&(n.sheen=this.sheen),this.sheenColor&&this.sheenColor.isColor&&(n.sheenColor=this.sheenColor.getHex()),this.sheenRoughness!==void 0&&(n.sheenRoughness=this.sheenRoughness),this.emissive&&this.emissive.isColor&&(n.emissive=this.emissive.getHex()),this.emissiveIntensity&&this.emissiveIntensity!==1&&(n.emissiveIntensity=this.emissiveIntensity),this.specular&&this.specular.isColor&&(n.specular=this.specular.getHex()),this.specularIntensity!==void 0&&(n.specularIntensity=this.specularIntensity),this.specularColor&&this.specularColor.isColor&&(n.specularColor=this.specularColor.getHex()),this.shininess!==void 0&&(n.shininess=this.shininess),this.clearcoat!==void 0&&(n.clearcoat=this.clearcoat),this.clearcoatRoughness!==void 0&&(n.clearcoatRoughness=this.clearcoatRoughness),this.clearcoatMap&&this.clearcoatMap.isTexture&&(n.clearcoatMap=this.clearcoatMap.toJSON(t).uuid),this.clearcoatRoughnessMap&&this.clearcoatRoughnessMap.isTexture&&(n.clearcoatRoughnessMap=this.clearcoatRoughnessMap.toJSON(t).uuid),this.clearcoatNormalMap&&this.clearcoatNormalMap.isTexture&&(n.clearcoatNormalMap=this.clearcoatNormalMap.toJSON(t).uuid,n.clearcoatNormalScale=this.clearcoatNormalScale.toArray()),this.iridescence!==void 0&&(n.iridescence=this.iridescence),this.iridescenceIOR!==void 0&&(n.iridescenceIOR=this.iridescenceIOR),this.iridescenceThicknessRange!==void 0&&(n.iridescenceThicknessRange=this.iridescenceThicknessRange),this.iridescenceMap&&this.iridescenceMap.isTexture&&(n.iridescenceMap=this.iridescenceMap.toJSON(t).uuid),this.iridescenceThicknessMap&&this.iridescenceThicknessMap.isTexture&&(n.iridescenceThicknessMap=this.iridescenceThicknessMap.toJSON(t).uuid),this.anisotropy!==void 0&&(n.anisotropy=this.anisotropy),this.anisotropyRotation!==void 0&&(n.anisotropyRotation=this.anisotropyRotation),this.anisotropyMap&&this.anisotropyMap.isTexture&&(n.anisotropyMap=this.anisotropyMap.toJSON(t).uuid),this.map&&this.map.isTexture&&(n.map=this.map.toJSON(t).uuid),this.matcap&&this.matcap.isTexture&&(n.matcap=this.matcap.toJSON(t).uuid),this.alphaMap&&this.alphaMap.isTexture&&(n.alphaMap=this.alphaMap.toJSON(t).uuid),this.lightMap&&this.lightMap.isTexture&&(n.lightMap=this.lightMap.toJSON(t).uuid,n.lightMapIntensity=this.lightMapIntensity),this.aoMap&&this.aoMap.isTexture&&(n.aoMap=this.aoMap.toJSON(t).uuid,n.aoMapIntensity=this.aoMapIntensity),this.bumpMap&&this.bumpMap.isTexture&&(n.bumpMap=this.bumpMap.toJSON(t).uuid,n.bumpScale=this.bumpScale),this.normalMap&&this.normalMap.isTexture&&(n.normalMap=this.normalMap.toJSON(t).uuid,n.normalMapType=this.normalMapType,n.normalScale=this.normalScale.toArray()),this.displacementMap&&this.displacementMap.isTexture&&(n.displacementMap=this.displacementMap.toJSON(t).uuid,n.displacementScale=this.displacementScale,n.displacementBias=this.displacementBias),this.roughnessMap&&this.roughnessMap.isTexture&&(n.roughnessMap=this.roughnessMap.toJSON(t).uuid),this.metalnessMap&&this.metalnessMap.isTexture&&(n.metalnessMap=this.metalnessMap.toJSON(t).uuid),this.emissiveMap&&this.emissiveMap.isTexture&&(n.emissiveMap=this.emissiveMap.toJSON(t).uuid),this.specularMap&&this.specularMap.isTexture&&(n.specularMap=this.specularMap.toJSON(t).uuid),this.specularIntensityMap&&this.specularIntensityMap.isTexture&&(n.specularIntensityMap=this.specularIntensityMap.toJSON(t).uuid),this.specularColorMap&&this.specularColorMap.isTexture&&(n.specularColorMap=this.specularColorMap.toJSON(t).uuid),this.envMap&&this.envMap.isTexture&&(n.envMap=this.envMap.toJSON(t).uuid,this.combine!==void 0&&(n.combine=this.combine)),this.envMapIntensity!==void 0&&(n.envMapIntensity=this.envMapIntensity),this.reflectivity!==void 0&&(n.reflectivity=this.reflectivity),this.refractionRatio!==void 0&&(n.refractionRatio=this.refractionRatio),this.gradientMap&&this.gradientMap.isTexture&&(n.gradientMap=this.gradientMap.toJSON(t).uuid),this.transmission!==void 0&&(n.transmission=this.transmission),this.transmissionMap&&this.transmissionMap.isTexture&&(n.transmissionMap=this.transmissionMap.toJSON(t).uuid),this.thickness!==void 0&&(n.thickness=this.thickness),this.thicknessMap&&this.thicknessMap.isTexture&&(n.thicknessMap=this.thicknessMap.toJSON(t).uuid),this.attenuationDistance!==void 0&&this.attenuationDistance!==1/0&&(n.attenuationDistance=this.attenuationDistance),this.attenuationColor!==void 0&&(n.attenuationColor=this.attenuationColor.getHex()),this.size!==void 0&&(n.size=this.size),this.shadowSide!==null&&(n.shadowSide=this.shadowSide),this.sizeAttenuation!==void 0&&(n.sizeAttenuation=this.sizeAttenuation),this.blending!==Wn&&(n.blending=this.blending),this.side!==un&&(n.side=this.side),this.vertexColors===!0&&(n.vertexColors=!0),this.opacity<1&&(n.opacity=this.opacity),this.transparent===!0&&(n.transparent=!0),this.blendSrc!==Ir&&(n.blendSrc=this.blendSrc),this.blendDst!==Nr&&(n.blendDst=this.blendDst),this.blendEquation!==yn&&(n.blendEquation=this.blendEquation),this.blendSrcAlpha!==null&&(n.blendSrcAlpha=this.blendSrcAlpha),this.blendDstAlpha!==null&&(n.blendDstAlpha=this.blendDstAlpha),this.blendEquationAlpha!==null&&(n.blendEquationAlpha=this.blendEquationAlpha),this.blendColor&&this.blendColor.isColor&&(n.blendColor=this.blendColor.getHex()),this.blendAlpha!==0&&(n.blendAlpha=this.blendAlpha),this.depthFunc!==Vi&&(n.depthFunc=this.depthFunc),this.depthTest===!1&&(n.depthTest=this.depthTest),this.depthWrite===!1&&(n.depthWrite=this.depthWrite),this.colorWrite===!1&&(n.colorWrite=this.colorWrite),this.stencilWriteMask!==255&&(n.stencilWriteMask=this.stencilWriteMask),this.stencilFunc!==za&&(n.stencilFunc=this.stencilFunc),this.stencilRef!==0&&(n.stencilRef=this.stencilRef),this.stencilFuncMask!==255&&(n.stencilFuncMask=this.stencilFuncMask),this.stencilFail!==An&&(n.stencilFail=this.stencilFail),this.stencilZFail!==An&&(n.stencilZFail=this.stencilZFail),this.stencilZPass!==An&&(n.stencilZPass=this.stencilZPass),this.stencilWrite===!0&&(n.stencilWrite=this.stencilWrite),this.rotation!==void 0&&this.rotation!==0&&(n.rotation=this.rotation),this.polygonOffset===!0&&(n.polygonOffset=!0),this.polygonOffsetFactor!==0&&(n.polygonOffsetFactor=this.polygonOffsetFactor),this.polygonOffsetUnits!==0&&(n.polygonOffsetUnits=this.polygonOffsetUnits),this.linewidth!==void 0&&this.linewidth!==1&&(n.linewidth=this.linewidth),this.dashSize!==void 0&&(n.dashSize=this.dashSize),this.gapSize!==void 0&&(n.gapSize=this.gapSize),this.scale!==void 0&&(n.scale=this.scale),this.dithering===!0&&(n.dithering=!0),this.alphaTest>0&&(n.alphaTest=this.alphaTest),this.alphaHash===!0&&(n.alphaHash=!0),this.alphaToCoverage===!0&&(n.alphaToCoverage=!0),this.premultipliedAlpha===!0&&(n.premultipliedAlpha=!0),this.forceSinglePass===!0&&(n.forceSinglePass=!0),this.wireframe===!0&&(n.wireframe=!0),this.wireframeLinewidth>1&&(n.wireframeLinewidth=this.wireframeLinewidth),this.wireframeLinecap!=="round"&&(n.wireframeLinecap=this.wireframeLinecap),this.wireframeLinejoin!=="round"&&(n.wireframeLinejoin=this.wireframeLinejoin),this.flatShading===!0&&(n.flatShading=!0),this.visible===!1&&(n.visible=!1),this.toneMapped===!1&&(n.toneMapped=!1),this.fog===!1&&(n.fog=!1),Object.keys(this.userData).length>0&&(n.userData=this.userData);function r(a){const o=[];for(const s in a){const l=a[s];delete l.metadata,o.push(l)}return o}if(e){const a=r(t.textures),o=r(t.images);a.length>0&&(n.textures=a),o.length>0&&(n.images=o)}return n}clone(){return new this.constructor().copy(this)}copy(t){this.name=t.name,this.blending=t.blending,this.side=t.side,this.vertexColors=t.vertexColors,this.opacity=t.opacity,this.transparent=t.transparent,this.blendSrc=t.blendSrc,this.blendDst=t.blendDst,this.blendEquation=t.blendEquation,this.blendSrcAlpha=t.blendSrcAlpha,this.blendDstAlpha=t.blendDstAlpha,this.blendEquationAlpha=t.blendEquationAlpha,this.blendColor.copy(t.blendColor),this.blendAlpha=t.blendAlpha,this.depthFunc=t.depthFunc,this.depthTest=t.depthTest,this.depthWrite=t.depthWrite,this.stencilWriteMask=t.stencilWriteMask,this.stencilFunc=t.stencilFunc,this.stencilRef=t.stencilRef,this.stencilFuncMask=t.stencilFuncMask,this.stencilFail=t.stencilFail,this.stencilZFail=t.stencilZFail,this.stencilZPass=t.stencilZPass,this.stencilWrite=t.stencilWrite;const e=t.clippingPlanes;let n=null;if(e!==null){const r=e.length;n=new Array(r);for(let a=0;a!==r;++a)n[a]=e[a].clone()}return this.clippingPlanes=n,this.clipIntersection=t.clipIntersection,this.clipShadows=t.clipShadows,this.shadowSide=t.shadowSide,this.colorWrite=t.colorWrite,this.precision=t.precision,this.polygonOffset=t.polygonOffset,this.polygonOffsetFactor=t.polygonOffsetFactor,this.polygonOffsetUnits=t.polygonOffsetUnits,this.dithering=t.dithering,this.alphaTest=t.alphaTest,this.alphaHash=t.alphaHash,this.alphaToCoverage=t.alphaToCoverage,this.premultipliedAlpha=t.premultipliedAlpha,this.forceSinglePass=t.forceSinglePass,this.visible=t.visible,this.toneMapped=t.toneMapped,this.userData=JSON.parse(JSON.stringify(t.userData)),this}dispose(){this.dispatchEvent({type:"dispose"})}set needsUpdate(t){t===!0&&this.version++}}class Ys extends ji{constructor(t){super(),this.isMeshBasicMaterial=!0,this.type="MeshBasicMaterial",this.color=new kt(16777215),this.map=null,this.lightMap=null,this.lightMapIntensity=1,this.aoMap=null,this.aoMapIntensity=1,this.specularMap=null,this.alphaMap=null,this.envMap=null,this.combine=Ps,this.reflectivity=1,this.refractionRatio=.98,this.wireframe=!1,this.wireframeLinewidth=1,this.wireframeLinecap="round",this.wireframeLinejoin="round",this.fog=!0,this.setValues(t)}copy(t){return super.copy(t),this.color.copy(t.color),this.map=t.map,this.lightMap=t.lightMap,this.lightMapIntensity=t.lightMapIntensity,this.aoMap=t.aoMap,this.aoMapIntensity=t.aoMapIntensity,this.specularMap=t.specularMap,this.alphaMap=t.alphaMap,this.envMap=t.envMap,this.combine=t.combine,this.reflectivity=t.reflectivity,this.refractionRatio=t.refractionRatio,this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this.wireframeLinecap=t.wireframeLinecap,this.wireframeLinejoin=t.wireframeLinejoin,this.fog=t.fog,this}}const ee=new L,Ai=new Wt;class ze{constructor(t,e,n=!1){if(Array.isArray(t))throw new TypeError("THREE.BufferAttribute: array should be a Typed Array.");this.isBufferAttribute=!0,this.name="",this.array=t,this.itemSize=e,this.count=t!==void 0?t.length/e:0,this.normalized=n,this.usage=Ba,this._updateRange={offset:0,count:-1},this.updateRanges=[],this.gpuType=$e,this.version=0}onUploadCallback(){}set needsUpdate(t){t===!0&&this.version++}get updateRange(){return console.warn("THREE.BufferAttribute: updateRange() is deprecated and will be removed in r169. Use addUpdateRange() instead."),this._updateRange}setUsage(t){return this.usage=t,this}addUpdateRange(t,e){this.updateRanges.push({start:t,count:e})}clearUpdateRanges(){this.updateRanges.length=0}copy(t){return this.name=t.name,this.array=new t.array.constructor(t.array),this.itemSize=t.itemSize,this.count=t.count,this.normalized=t.normalized,this.usage=t.usage,this.gpuType=t.gpuType,this}copyAt(t,e,n){t*=this.itemSize,n*=e.itemSize;for(let r=0,a=this.itemSize;r<a;r++)this.array[t+r]=e.array[n+r];return this}copyArray(t){return this.array.set(t),this}applyMatrix3(t){if(this.itemSize===2)for(let e=0,n=this.count;e<n;e++)Ai.fromBufferAttribute(this,e),Ai.applyMatrix3(t),this.setXY(e,Ai.x,Ai.y);else if(this.itemSize===3)for(let e=0,n=this.count;e<n;e++)ee.fromBufferAttribute(this,e),ee.applyMatrix3(t),this.setXYZ(e,ee.x,ee.y,ee.z);return this}applyMatrix4(t){for(let e=0,n=this.count;e<n;e++)ee.fromBufferAttribute(this,e),ee.applyMatrix4(t),this.setXYZ(e,ee.x,ee.y,ee.z);return this}applyNormalMatrix(t){for(let e=0,n=this.count;e<n;e++)ee.fromBufferAttribute(this,e),ee.applyNormalMatrix(t),this.setXYZ(e,ee.x,ee.y,ee.z);return this}transformDirection(t){for(let e=0,n=this.count;e<n;e++)ee.fromBufferAttribute(this,e),ee.transformDirection(t),this.setXYZ(e,ee.x,ee.y,ee.z);return this}set(t,e=0){return this.array.set(t,e),this}getComponent(t,e){let n=this.array[t*this.itemSize+e];return this.normalized&&(n=Qn(n,this.array)),n}setComponent(t,e,n){return this.normalized&&(n=_e(n,this.array)),this.array[t*this.itemSize+e]=n,this}getX(t){let e=this.array[t*this.itemSize];return this.normalized&&(e=Qn(e,this.array)),e}setX(t,e){return this.normalized&&(e=_e(e,this.array)),this.array[t*this.itemSize]=e,this}getY(t){let e=this.array[t*this.itemSize+1];return this.normalized&&(e=Qn(e,this.array)),e}setY(t,e){return this.normalized&&(e=_e(e,this.array)),this.array[t*this.itemSize+1]=e,this}getZ(t){let e=this.array[t*this.itemSize+2];return this.normalized&&(e=Qn(e,this.array)),e}setZ(t,e){return this.normalized&&(e=_e(e,this.array)),this.array[t*this.itemSize+2]=e,this}getW(t){let e=this.array[t*this.itemSize+3];return this.normalized&&(e=Qn(e,this.array)),e}setW(t,e){return this.normalized&&(e=_e(e,this.array)),this.array[t*this.itemSize+3]=e,this}setXY(t,e,n){return t*=this.itemSize,this.normalized&&(e=_e(e,this.array),n=_e(n,this.array)),this.array[t+0]=e,this.array[t+1]=n,this}setXYZ(t,e,n,r){return t*=this.itemSize,this.normalized&&(e=_e(e,this.array),n=_e(n,this.array),r=_e(r,this.array)),this.array[t+0]=e,this.array[t+1]=n,this.array[t+2]=r,this}setXYZW(t,e,n,r,a){return t*=this.itemSize,this.normalized&&(e=_e(e,this.array),n=_e(n,this.array),r=_e(r,this.array),a=_e(a,this.array)),this.array[t+0]=e,this.array[t+1]=n,this.array[t+2]=r,this.array[t+3]=a,this}onUpload(t){return this.onUploadCallback=t,this}clone(){return new this.constructor(this.array,this.itemSize).copy(this)}toJSON(){const t={itemSize:this.itemSize,type:this.array.constructor.name,array:Array.from(this.array),normalized:this.normalized};return this.name!==""&&(t.name=this.name),this.usage!==Ba&&(t.usage=this.usage),t}}class $s extends ze{constructor(t,e,n){super(new Uint16Array(t),e,n)}}class js extends ze{constructor(t,e,n){super(new Uint32Array(t),e,n)}}class Ke extends ze{constructor(t,e,n){super(new Float32Array(t),e,n)}}let Fl=0;const we=new Kt,Mr=new be,Nn=new L,Me=new di,ii=new di,se=new L;class dn extends Zn{constructor(){super(),this.isBufferGeometry=!0,Object.defineProperty(this,"id",{value:Fl++}),this.uuid=ui(),this.name="",this.type="BufferGeometry",this.index=null,this.attributes={},this.morphAttributes={},this.morphTargetsRelative=!1,this.groups=[],this.boundingBox=null,this.boundingSphere=null,this.drawRange={start:0,count:1/0},this.userData={}}getIndex(){return this.index}setIndex(t){return Array.isArray(t)?this.index=new(Hs(t)?js:$s)(t,1):this.index=t,this}getAttribute(t){return this.attributes[t]}setAttribute(t,e){return this.attributes[t]=e,this}deleteAttribute(t){return delete this.attributes[t],this}hasAttribute(t){return this.attributes[t]!==void 0}addGroup(t,e,n=0){this.groups.push({start:t,count:e,materialIndex:n})}clearGroups(){this.groups=[]}setDrawRange(t,e){this.drawRange.start=t,this.drawRange.count=e}applyMatrix4(t){const e=this.attributes.position;e!==void 0&&(e.applyMatrix4(t),e.needsUpdate=!0);const n=this.attributes.normal;if(n!==void 0){const a=new Ct().getNormalMatrix(t);n.applyNormalMatrix(a),n.needsUpdate=!0}const r=this.attributes.tangent;return r!==void 0&&(r.transformDirection(t),r.needsUpdate=!0),this.boundingBox!==null&&this.computeBoundingBox(),this.boundingSphere!==null&&this.computeBoundingSphere(),this}applyQuaternion(t){return we.makeRotationFromQuaternion(t),this.applyMatrix4(we),this}rotateX(t){return we.makeRotationX(t),this.applyMatrix4(we),this}rotateY(t){return we.makeRotationY(t),this.applyMatrix4(we),this}rotateZ(t){return we.makeRotationZ(t),this.applyMatrix4(we),this}translate(t,e,n){return we.makeTranslation(t,e,n),this.applyMatrix4(we),this}scale(t,e,n){return we.makeScale(t,e,n),this.applyMatrix4(we),this}lookAt(t){return Mr.lookAt(t),Mr.updateMatrix(),this.applyMatrix4(Mr.matrix),this}center(){return this.computeBoundingBox(),this.boundingBox.getCenter(Nn).negate(),this.translate(Nn.x,Nn.y,Nn.z),this}setFromPoints(t){const e=[];for(let n=0,r=t.length;n<r;n++){const a=t[n];e.push(a.x,a.y,a.z||0)}return this.setAttribute("position",new Ke(e,3)),this}computeBoundingBox(){this.boundingBox===null&&(this.boundingBox=new di);const t=this.attributes.position,e=this.morphAttributes.position;if(t&&t.isGLBufferAttribute){console.error('THREE.BufferGeometry.computeBoundingBox(): GLBufferAttribute requires a manual bounding box. Alternatively set "mesh.frustumCulled" to "false".',this),this.boundingBox.set(new L(-1/0,-1/0,-1/0),new L(1/0,1/0,1/0));return}if(t!==void 0){if(this.boundingBox.setFromBufferAttribute(t),e)for(let n=0,r=e.length;n<r;n++){const a=e[n];Me.setFromBufferAttribute(a),this.morphTargetsRelative?(se.addVectors(this.boundingBox.min,Me.min),this.boundingBox.expandByPoint(se),se.addVectors(this.boundingBox.max,Me.max),this.boundingBox.expandByPoint(se)):(this.boundingBox.expandByPoint(Me.min),this.boundingBox.expandByPoint(Me.max))}}else this.boundingBox.makeEmpty();(isNaN(this.boundingBox.min.x)||isNaN(this.boundingBox.min.y)||isNaN(this.boundingBox.min.z))&&console.error('THREE.BufferGeometry.computeBoundingBox(): Computed min/max have NaN values. The "position" attribute is likely to have NaN values.',this)}computeBoundingSphere(){this.boundingSphere===null&&(this.boundingSphere=new $r);const t=this.attributes.position,e=this.morphAttributes.position;if(t&&t.isGLBufferAttribute){console.error('THREE.BufferGeometry.computeBoundingSphere(): GLBufferAttribute requires a manual bounding sphere. Alternatively set "mesh.frustumCulled" to "false".',this),this.boundingSphere.set(new L,1/0);return}if(t){const n=this.boundingSphere.center;if(Me.setFromBufferAttribute(t),e)for(let a=0,o=e.length;a<o;a++){const s=e[a];ii.setFromBufferAttribute(s),this.morphTargetsRelative?(se.addVectors(Me.min,ii.min),Me.expandByPoint(se),se.addVectors(Me.max,ii.max),Me.expandByPoint(se)):(Me.expandByPoint(ii.min),Me.expandByPoint(ii.max))}Me.getCenter(n);let r=0;for(let a=0,o=t.count;a<o;a++)se.fromBufferAttribute(t,a),r=Math.max(r,n.distanceToSquared(se));if(e)for(let a=0,o=e.length;a<o;a++){const s=e[a],l=this.morphTargetsRelative;for(let c=0,u=s.count;c<u;c++)se.fromBufferAttribute(s,c),l&&(Nn.fromBufferAttribute(t,c),se.add(Nn)),r=Math.max(r,n.distanceToSquared(se))}this.boundingSphere.radius=Math.sqrt(r),isNaN(this.boundingSphere.radius)&&console.error('THREE.BufferGeometry.computeBoundingSphere(): Computed radius is NaN. The "position" attribute is likely to have NaN values.',this)}}computeTangents(){const t=this.index,e=this.attributes;if(t===null||e.position===void 0||e.normal===void 0||e.uv===void 0){console.error("THREE.BufferGeometry: .computeTangents() failed. Missing required attributes (index, position, normal or uv)");return}const n=t.array,r=e.position.array,a=e.normal.array,o=e.uv.array,s=r.length/3;this.hasAttribute("tangent")===!1&&this.setAttribute("tangent",new ze(new Float32Array(4*s),4));const l=this.getAttribute("tangent").array,c=[],u=[];for(let M=0;M<s;M++)c[M]=new L,u[M]=new L;const d=new L,f=new L,m=new L,v=new Wt,_=new Wt,p=new Wt,h=new L,E=new L;function T(M,H,k){d.fromArray(r,M*3),f.fromArray(r,H*3),m.fromArray(r,k*3),v.fromArray(o,M*2),_.fromArray(o,H*2),p.fromArray(o,k*2),f.sub(d),m.sub(d),_.sub(v),p.sub(v);const it=1/(_.x*p.y-p.x*_.y);isFinite(it)&&(h.copy(f).multiplyScalar(p.y).addScaledVector(m,-_.y).multiplyScalar(it),E.copy(m).multiplyScalar(_.x).addScaledVector(f,-p.x).multiplyScalar(it),c[M].add(h),c[H].add(h),c[k].add(h),u[M].add(E),u[H].add(E),u[k].add(E))}let b=this.groups;b.length===0&&(b=[{start:0,count:n.length}]);for(let M=0,H=b.length;M<H;++M){const k=b[M],it=k.start,C=k.count;for(let z=it,V=it+C;z<V;z+=3)T(n[z+0],n[z+1],n[z+2])}const D=new L,R=new L,w=new L,Z=new L;function y(M){w.fromArray(a,M*3),Z.copy(w);const H=c[M];D.copy(H),D.sub(w.multiplyScalar(w.dot(H))).normalize(),R.crossVectors(Z,H);const it=R.dot(u[M])<0?-1:1;l[M*4]=D.x,l[M*4+1]=D.y,l[M*4+2]=D.z,l[M*4+3]=it}for(let M=0,H=b.length;M<H;++M){const k=b[M],it=k.start,C=k.count;for(let z=it,V=it+C;z<V;z+=3)y(n[z+0]),y(n[z+1]),y(n[z+2])}}computeVertexNormals(){const t=this.index,e=this.getAttribute("position");if(e!==void 0){let n=this.getAttribute("normal");if(n===void 0)n=new ze(new Float32Array(e.count*3),3),this.setAttribute("normal",n);else for(let f=0,m=n.count;f<m;f++)n.setXYZ(f,0,0,0);const r=new L,a=new L,o=new L,s=new L,l=new L,c=new L,u=new L,d=new L;if(t)for(let f=0,m=t.count;f<m;f+=3){const v=t.getX(f+0),_=t.getX(f+1),p=t.getX(f+2);r.fromBufferAttribute(e,v),a.fromBufferAttribute(e,_),o.fromBufferAttribute(e,p),u.subVectors(o,a),d.subVectors(r,a),u.cross(d),s.fromBufferAttribute(n,v),l.fromBufferAttribute(n,_),c.fromBufferAttribute(n,p),s.add(u),l.add(u),c.add(u),n.setXYZ(v,s.x,s.y,s.z),n.setXYZ(_,l.x,l.y,l.z),n.setXYZ(p,c.x,c.y,c.z)}else for(let f=0,m=e.count;f<m;f+=3)r.fromBufferAttribute(e,f+0),a.fromBufferAttribute(e,f+1),o.fromBufferAttribute(e,f+2),u.subVectors(o,a),d.subVectors(r,a),u.cross(d),n.setXYZ(f+0,u.x,u.y,u.z),n.setXYZ(f+1,u.x,u.y,u.z),n.setXYZ(f+2,u.x,u.y,u.z);this.normalizeNormals(),n.needsUpdate=!0}}normalizeNormals(){const t=this.attributes.normal;for(let e=0,n=t.count;e<n;e++)se.fromBufferAttribute(t,e),se.normalize(),t.setXYZ(e,se.x,se.y,se.z)}toNonIndexed(){function t(s,l){const c=s.array,u=s.itemSize,d=s.normalized,f=new c.constructor(l.length*u);let m=0,v=0;for(let _=0,p=l.length;_<p;_++){s.isInterleavedBufferAttribute?m=l[_]*s.data.stride+s.offset:m=l[_]*u;for(let h=0;h<u;h++)f[v++]=c[m++]}return new ze(f,u,d)}if(this.index===null)return console.warn("THREE.BufferGeometry.toNonIndexed(): BufferGeometry is already non-indexed."),this;const e=new dn,n=this.index.array,r=this.attributes;for(const s in r){const l=r[s],c=t(l,n);e.setAttribute(s,c)}const a=this.morphAttributes;for(const s in a){const l=[],c=a[s];for(let u=0,d=c.length;u<d;u++){const f=c[u],m=t(f,n);l.push(m)}e.morphAttributes[s]=l}e.morphTargetsRelative=this.morphTargetsRelative;const o=this.groups;for(let s=0,l=o.length;s<l;s++){const c=o[s];e.addGroup(c.start,c.count,c.materialIndex)}return e}toJSON(){const t={metadata:{version:4.6,type:"BufferGeometry",generator:"BufferGeometry.toJSON"}};if(t.uuid=this.uuid,t.type=this.type,this.name!==""&&(t.name=this.name),Object.keys(this.userData).length>0&&(t.userData=this.userData),this.parameters!==void 0){const l=this.parameters;for(const c in l)l[c]!==void 0&&(t[c]=l[c]);return t}t.data={attributes:{}};const e=this.index;e!==null&&(t.data.index={type:e.array.constructor.name,array:Array.prototype.slice.call(e.array)});const n=this.attributes;for(const l in n){const c=n[l];t.data.attributes[l]=c.toJSON(t.data)}const r={};let a=!1;for(const l in this.morphAttributes){const c=this.morphAttributes[l],u=[];for(let d=0,f=c.length;d<f;d++){const m=c[d];u.push(m.toJSON(t.data))}u.length>0&&(r[l]=u,a=!0)}a&&(t.data.morphAttributes=r,t.data.morphTargetsRelative=this.morphTargetsRelative);const o=this.groups;o.length>0&&(t.data.groups=JSON.parse(JSON.stringify(o)));const s=this.boundingSphere;return s!==null&&(t.data.boundingSphere={center:s.center.toArray(),radius:s.radius}),t}clone(){return new this.constructor().copy(this)}copy(t){this.index=null,this.attributes={},this.morphAttributes={},this.groups=[],this.boundingBox=null,this.boundingSphere=null;const e={};this.name=t.name;const n=t.index;n!==null&&this.setIndex(n.clone(e));const r=t.attributes;for(const c in r){const u=r[c];this.setAttribute(c,u.clone(e))}const a=t.morphAttributes;for(const c in a){const u=[],d=a[c];for(let f=0,m=d.length;f<m;f++)u.push(d[f].clone(e));this.morphAttributes[c]=u}this.morphTargetsRelative=t.morphTargetsRelative;const o=t.groups;for(let c=0,u=o.length;c<u;c++){const d=o[c];this.addGroup(d.start,d.count,d.materialIndex)}const s=t.boundingBox;s!==null&&(this.boundingBox=s.clone());const l=t.boundingSphere;return l!==null&&(this.boundingSphere=l.clone()),this.drawRange.start=t.drawRange.start,this.drawRange.count=t.drawRange.count,this.userData=t.userData,this}dispose(){this.dispatchEvent({type:"dispose"})}}const Qa=new Kt,_n=new wl,wi=new $r,ts=new L,Fn=new L,On=new L,zn=new L,Er=new L,Ri=new L,Ci=new Wt,Pi=new Wt,Li=new Wt,es=new L,ns=new L,is=new L,Di=new L,Ui=new L;class Ze extends be{constructor(t=new dn,e=new Ys){super(),this.isMesh=!0,this.type="Mesh",this.geometry=t,this.material=e,this.updateMorphTargets()}copy(t,e){return super.copy(t,e),t.morphTargetInfluences!==void 0&&(this.morphTargetInfluences=t.morphTargetInfluences.slice()),t.morphTargetDictionary!==void 0&&(this.morphTargetDictionary=Object.assign({},t.morphTargetDictionary)),this.material=Array.isArray(t.material)?t.material.slice():t.material,this.geometry=t.geometry,this}updateMorphTargets(){const e=this.geometry.morphAttributes,n=Object.keys(e);if(n.length>0){const r=e[n[0]];if(r!==void 0){this.morphTargetInfluences=[],this.morphTargetDictionary={};for(let a=0,o=r.length;a<o;a++){const s=r[a].name||String(a);this.morphTargetInfluences.push(0),this.morphTargetDictionary[s]=a}}}}getVertexPosition(t,e){const n=this.geometry,r=n.attributes.position,a=n.morphAttributes.position,o=n.morphTargetsRelative;e.fromBufferAttribute(r,t);const s=this.morphTargetInfluences;if(a&&s){Ri.set(0,0,0);for(let l=0,c=a.length;l<c;l++){const u=s[l],d=a[l];u!==0&&(Er.fromBufferAttribute(d,t),o?Ri.addScaledVector(Er,u):Ri.addScaledVector(Er.sub(e),u))}e.add(Ri)}return e}raycast(t,e){const n=this.geometry,r=this.material,a=this.matrixWorld;r!==void 0&&(n.boundingSphere===null&&n.computeBoundingSphere(),wi.copy(n.boundingSphere),wi.applyMatrix4(a),_n.copy(t.ray).recast(t.near),!(wi.containsPoint(_n.origin)===!1&&(_n.intersectSphere(wi,ts)===null||_n.origin.distanceToSquared(ts)>(t.far-t.near)**2))&&(Qa.copy(a).invert(),_n.copy(t.ray).applyMatrix4(Qa),!(n.boundingBox!==null&&_n.intersectsBox(n.boundingBox)===!1)&&this._computeIntersections(t,e,_n)))}_computeIntersections(t,e,n){let r;const a=this.geometry,o=this.material,s=a.index,l=a.attributes.position,c=a.attributes.uv,u=a.attributes.uv1,d=a.attributes.normal,f=a.groups,m=a.drawRange;if(s!==null)if(Array.isArray(o))for(let v=0,_=f.length;v<_;v++){const p=f[v],h=o[p.materialIndex],E=Math.max(p.start,m.start),T=Math.min(s.count,Math.min(p.start+p.count,m.start+m.count));for(let b=E,D=T;b<D;b+=3){const R=s.getX(b),w=s.getX(b+1),Z=s.getX(b+2);r=Ii(this,h,t,n,c,u,d,R,w,Z),r&&(r.faceIndex=Math.floor(b/3),r.face.materialIndex=p.materialIndex,e.push(r))}}else{const v=Math.max(0,m.start),_=Math.min(s.count,m.start+m.count);for(let p=v,h=_;p<h;p+=3){const E=s.getX(p),T=s.getX(p+1),b=s.getX(p+2);r=Ii(this,o,t,n,c,u,d,E,T,b),r&&(r.faceIndex=Math.floor(p/3),e.push(r))}}else if(l!==void 0)if(Array.isArray(o))for(let v=0,_=f.length;v<_;v++){const p=f[v],h=o[p.materialIndex],E=Math.max(p.start,m.start),T=Math.min(l.count,Math.min(p.start+p.count,m.start+m.count));for(let b=E,D=T;b<D;b+=3){const R=b,w=b+1,Z=b+2;r=Ii(this,h,t,n,c,u,d,R,w,Z),r&&(r.faceIndex=Math.floor(b/3),r.face.materialIndex=p.materialIndex,e.push(r))}}else{const v=Math.max(0,m.start),_=Math.min(l.count,m.start+m.count);for(let p=v,h=_;p<h;p+=3){const E=p,T=p+1,b=p+2;r=Ii(this,o,t,n,c,u,d,E,T,b),r&&(r.faceIndex=Math.floor(p/3),e.push(r))}}}}function Ol(i,t,e,n,r,a,o,s){let l;if(t.side===xe?l=n.intersectTriangle(o,a,r,!0,s):l=n.intersectTriangle(r,a,o,t.side===un,s),l===null)return null;Ui.copy(s),Ui.applyMatrix4(i.matrixWorld);const c=e.ray.origin.distanceTo(Ui);return c<e.near||c>e.far?null:{distance:c,point:Ui.clone(),object:i}}function Ii(i,t,e,n,r,a,o,s,l,c){i.getVertexPosition(s,Fn),i.getVertexPosition(l,On),i.getVertexPosition(c,zn);const u=Ol(i,t,e,n,Fn,On,zn,Di);if(u){r&&(Ci.fromBufferAttribute(r,s),Pi.fromBufferAttribute(r,l),Li.fromBufferAttribute(r,c),u.uv=Ie.getInterpolation(Di,Fn,On,zn,Ci,Pi,Li,new Wt)),a&&(Ci.fromBufferAttribute(a,s),Pi.fromBufferAttribute(a,l),Li.fromBufferAttribute(a,c),u.uv1=Ie.getInterpolation(Di,Fn,On,zn,Ci,Pi,Li,new Wt),u.uv2=u.uv1),o&&(es.fromBufferAttribute(o,s),ns.fromBufferAttribute(o,l),is.fromBufferAttribute(o,c),u.normal=Ie.getInterpolation(Di,Fn,On,zn,es,ns,is,new L),u.normal.dot(n.direction)>0&&u.normal.multiplyScalar(-1));const d={a:s,b:l,c,normal:new L,materialIndex:0};Ie.getNormal(Fn,On,zn,d.normal),u.face=d}return u}class fi extends dn{constructor(t=1,e=1,n=1,r=1,a=1,o=1){super(),this.type="BoxGeometry",this.parameters={width:t,height:e,depth:n,widthSegments:r,heightSegments:a,depthSegments:o};const s=this;r=Math.floor(r),a=Math.floor(a),o=Math.floor(o);const l=[],c=[],u=[],d=[];let f=0,m=0;v("z","y","x",-1,-1,n,e,t,o,a,0),v("z","y","x",1,-1,n,e,-t,o,a,1),v("x","z","y",1,1,t,n,e,r,o,2),v("x","z","y",1,-1,t,n,-e,r,o,3),v("x","y","z",1,-1,t,e,n,r,a,4),v("x","y","z",-1,-1,t,e,-n,r,a,5),this.setIndex(l),this.setAttribute("position",new Ke(c,3)),this.setAttribute("normal",new Ke(u,3)),this.setAttribute("uv",new Ke(d,2));function v(_,p,h,E,T,b,D,R,w,Z,y){const M=b/w,H=D/Z,k=b/2,it=D/2,C=R/2,z=w+1,V=Z+1;let X=0,G=0;const W=new L;for(let q=0;q<V;q++){const Q=q*H-it;for(let tt=0;tt<z;tt++){const B=tt*M-k;W[_]=B*E,W[p]=Q*T,W[h]=C,c.push(W.x,W.y,W.z),W[_]=0,W[p]=0,W[h]=R>0?1:-1,u.push(W.x,W.y,W.z),d.push(tt/w),d.push(1-q/Z),X+=1}}for(let q=0;q<Z;q++)for(let Q=0;Q<w;Q++){const tt=f+Q+z*q,B=f+Q+z*(q+1),Y=f+(Q+1)+z*(q+1),ot=f+(Q+1)+z*q;l.push(tt,B,ot),l.push(B,Y,ot),G+=6}s.addGroup(m,G,y),m+=G,f+=X}}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new fi(t.width,t.height,t.depth,t.widthSegments,t.heightSegments,t.depthSegments)}}function jn(i){const t={};for(const e in i){t[e]={};for(const n in i[e]){const r=i[e][n];r&&(r.isColor||r.isMatrix3||r.isMatrix4||r.isVector2||r.isVector3||r.isVector4||r.isTexture||r.isQuaternion)?r.isRenderTargetTexture?(console.warn("UniformsUtils: Textures of render targets cannot be cloned via cloneUniforms() or mergeUniforms()."),t[e][n]=null):t[e][n]=r.clone():Array.isArray(r)?t[e][n]=r.slice():t[e][n]=r}}return t}function ge(i){const t={};for(let e=0;e<i.length;e++){const n=jn(i[e]);for(const r in n)t[r]=n[r]}return t}function zl(i){const t=[];for(let e=0;e<i.length;e++)t.push(i[e].clone());return t}function Zs(i){return i.getRenderTarget()===null?i.outputColorSpace:Gt.workingColorSpace}const Bl={clone:jn,merge:ge};var Vl=`void main() {
	gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}`,Hl=`void main() {
	gl_FragColor = vec4( 1.0, 0.0, 0.0, 1.0 );
}`;class hn extends ji{constructor(t){super(),this.isShaderMaterial=!0,this.type="ShaderMaterial",this.defines={},this.uniforms={},this.uniformsGroups=[],this.vertexShader=Vl,this.fragmentShader=Hl,this.linewidth=1,this.wireframe=!1,this.wireframeLinewidth=1,this.fog=!1,this.lights=!1,this.clipping=!1,this.forceSinglePass=!0,this.extensions={derivatives:!1,fragDepth:!1,drawBuffers:!1,shaderTextureLOD:!1,clipCullDistance:!1},this.defaultAttributeValues={color:[1,1,1],uv:[0,0],uv1:[0,0]},this.index0AttributeName=void 0,this.uniformsNeedUpdate=!1,this.glslVersion=null,t!==void 0&&this.setValues(t)}copy(t){return super.copy(t),this.fragmentShader=t.fragmentShader,this.vertexShader=t.vertexShader,this.uniforms=jn(t.uniforms),this.uniformsGroups=zl(t.uniformsGroups),this.defines=Object.assign({},t.defines),this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this.fog=t.fog,this.lights=t.lights,this.clipping=t.clipping,this.extensions=Object.assign({},t.extensions),this.glslVersion=t.glslVersion,this}toJSON(t){const e=super.toJSON(t);e.glslVersion=this.glslVersion,e.uniforms={};for(const r in this.uniforms){const o=this.uniforms[r].value;o&&o.isTexture?e.uniforms[r]={type:"t",value:o.toJSON(t).uuid}:o&&o.isColor?e.uniforms[r]={type:"c",value:o.getHex()}:o&&o.isVector2?e.uniforms[r]={type:"v2",value:o.toArray()}:o&&o.isVector3?e.uniforms[r]={type:"v3",value:o.toArray()}:o&&o.isVector4?e.uniforms[r]={type:"v4",value:o.toArray()}:o&&o.isMatrix3?e.uniforms[r]={type:"m3",value:o.toArray()}:o&&o.isMatrix4?e.uniforms[r]={type:"m4",value:o.toArray()}:e.uniforms[r]={value:o}}Object.keys(this.defines).length>0&&(e.defines=this.defines),e.vertexShader=this.vertexShader,e.fragmentShader=this.fragmentShader,e.lights=this.lights,e.clipping=this.clipping;const n={};for(const r in this.extensions)this.extensions[r]===!0&&(n[r]=!0);return Object.keys(n).length>0&&(e.extensions=n),e}}class Ks extends be{constructor(){super(),this.isCamera=!0,this.type="Camera",this.matrixWorldInverse=new Kt,this.projectionMatrix=new Kt,this.projectionMatrixInverse=new Kt,this.coordinateSystem=je}copy(t,e){return super.copy(t,e),this.matrixWorldInverse.copy(t.matrixWorldInverse),this.projectionMatrix.copy(t.projectionMatrix),this.projectionMatrixInverse.copy(t.projectionMatrixInverse),this.coordinateSystem=t.coordinateSystem,this}getWorldDirection(t){return super.getWorldDirection(t).negate()}updateMatrixWorld(t){super.updateMatrixWorld(t),this.matrixWorldInverse.copy(this.matrixWorld).invert()}updateWorldMatrix(t,e){super.updateWorldMatrix(t,e),this.matrixWorldInverse.copy(this.matrixWorld).invert()}clone(){return new this.constructor().copy(this)}}class Ne extends Ks{constructor(t=50,e=1,n=.1,r=2e3){super(),this.isPerspectiveCamera=!0,this.type="PerspectiveCamera",this.fov=t,this.zoom=1,this.near=n,this.far=r,this.focus=10,this.aspect=e,this.view=null,this.filmGauge=35,this.filmOffset=0,this.updateProjectionMatrix()}copy(t,e){return super.copy(t,e),this.fov=t.fov,this.zoom=t.zoom,this.near=t.near,this.far=t.far,this.focus=t.focus,this.aspect=t.aspect,this.view=t.view===null?null:Object.assign({},t.view),this.filmGauge=t.filmGauge,this.filmOffset=t.filmOffset,this}setFocalLength(t){const e=.5*this.getFilmHeight()/t;this.fov=Hr*2*Math.atan(e),this.updateProjectionMatrix()}getFocalLength(){const t=Math.tan(or*.5*this.fov);return .5*this.getFilmHeight()/t}getEffectiveFOV(){return Hr*2*Math.atan(Math.tan(or*.5*this.fov)/this.zoom)}getFilmWidth(){return this.filmGauge*Math.min(this.aspect,1)}getFilmHeight(){return this.filmGauge/Math.max(this.aspect,1)}setViewOffset(t,e,n,r,a,o){this.aspect=t/e,this.view===null&&(this.view={enabled:!0,fullWidth:1,fullHeight:1,offsetX:0,offsetY:0,width:1,height:1}),this.view.enabled=!0,this.view.fullWidth=t,this.view.fullHeight=e,this.view.offsetX=n,this.view.offsetY=r,this.view.width=a,this.view.height=o,this.updateProjectionMatrix()}clearViewOffset(){this.view!==null&&(this.view.enabled=!1),this.updateProjectionMatrix()}updateProjectionMatrix(){const t=this.near;let e=t*Math.tan(or*.5*this.fov)/this.zoom,n=2*e,r=this.aspect*n,a=-.5*r;const o=this.view;if(this.view!==null&&this.view.enabled){const l=o.fullWidth,c=o.fullHeight;a+=o.offsetX*r/l,e-=o.offsetY*n/c,r*=o.width/l,n*=o.height/c}const s=this.filmOffset;s!==0&&(a+=t*s/this.getFilmWidth()),this.projectionMatrix.makePerspective(a,a+r,e,e-n,t,this.far,this.coordinateSystem),this.projectionMatrixInverse.copy(this.projectionMatrix).invert()}toJSON(t){const e=super.toJSON(t);return e.object.fov=this.fov,e.object.zoom=this.zoom,e.object.near=this.near,e.object.far=this.far,e.object.focus=this.focus,e.object.aspect=this.aspect,this.view!==null&&(e.object.view=Object.assign({},this.view)),e.object.filmGauge=this.filmGauge,e.object.filmOffset=this.filmOffset,e}}const Bn=-90,Vn=1;class Gl extends be{constructor(t,e,n){super(),this.type="CubeCamera",this.renderTarget=n,this.coordinateSystem=null,this.activeMipmapLevel=0;const r=new Ne(Bn,Vn,t,e);r.layers=this.layers,this.add(r);const a=new Ne(Bn,Vn,t,e);a.layers=this.layers,this.add(a);const o=new Ne(Bn,Vn,t,e);o.layers=this.layers,this.add(o);const s=new Ne(Bn,Vn,t,e);s.layers=this.layers,this.add(s);const l=new Ne(Bn,Vn,t,e);l.layers=this.layers,this.add(l);const c=new Ne(Bn,Vn,t,e);c.layers=this.layers,this.add(c)}updateCoordinateSystem(){const t=this.coordinateSystem,e=this.children.concat(),[n,r,a,o,s,l]=e;for(const c of e)this.remove(c);if(t===je)n.up.set(0,1,0),n.lookAt(1,0,0),r.up.set(0,1,0),r.lookAt(-1,0,0),a.up.set(0,0,-1),a.lookAt(0,1,0),o.up.set(0,0,1),o.lookAt(0,-1,0),s.up.set(0,1,0),s.lookAt(0,0,1),l.up.set(0,1,0),l.lookAt(0,0,-1);else if(t===Wi)n.up.set(0,-1,0),n.lookAt(-1,0,0),r.up.set(0,-1,0),r.lookAt(1,0,0),a.up.set(0,0,1),a.lookAt(0,1,0),o.up.set(0,0,-1),o.lookAt(0,-1,0),s.up.set(0,-1,0),s.lookAt(0,0,1),l.up.set(0,-1,0),l.lookAt(0,0,-1);else throw new Error("THREE.CubeCamera.updateCoordinateSystem(): Invalid coordinate system: "+t);for(const c of e)this.add(c),c.updateMatrixWorld()}update(t,e){this.parent===null&&this.updateMatrixWorld();const{renderTarget:n,activeMipmapLevel:r}=this;this.coordinateSystem!==t.coordinateSystem&&(this.coordinateSystem=t.coordinateSystem,this.updateCoordinateSystem());const[a,o,s,l,c,u]=this.children,d=t.getRenderTarget(),f=t.getActiveCubeFace(),m=t.getActiveMipmapLevel(),v=t.xr.enabled;t.xr.enabled=!1;const _=n.texture.generateMipmaps;n.texture.generateMipmaps=!1,t.setRenderTarget(n,0,r),t.render(e,a),t.setRenderTarget(n,1,r),t.render(e,o),t.setRenderTarget(n,2,r),t.render(e,s),t.setRenderTarget(n,3,r),t.render(e,l),t.setRenderTarget(n,4,r),t.render(e,c),n.texture.generateMipmaps=_,t.setRenderTarget(n,5,r),t.render(e,u),t.setRenderTarget(d,f,m),t.xr.enabled=v,n.texture.needsPMREMUpdate=!0}}class Js extends Se{constructor(t,e,n,r,a,o,s,l,c,u){t=t!==void 0?t:[],e=e!==void 0?e:qn,super(t,e,n,r,a,o,s,l,c,u),this.isCubeTexture=!0,this.flipY=!1}get images(){return this.image}set images(t){this.image=t}}class kl extends Qe{constructor(t=1,e={}){super(t,t,e),this.isWebGLCubeRenderTarget=!0;const n={width:t,height:t,depth:1},r=[n,n,n,n,n,n];e.encoding!==void 0&&(ai("THREE.WebGLCubeRenderTarget: option.encoding has been replaced by option.colorSpace."),e.colorSpace=e.encoding===bn?le:Pe),this.texture=new Js(r,e.mapping,e.wrapS,e.wrapT,e.magFilter,e.minFilter,e.format,e.type,e.anisotropy,e.colorSpace),this.texture.isRenderTargetTexture=!0,this.texture.generateMipmaps=e.generateMipmaps!==void 0?e.generateMipmaps:!1,this.texture.minFilter=e.minFilter!==void 0?e.minFilter:Re}fromEquirectangularTexture(t,e){this.texture.type=e.type,this.texture.colorSpace=e.colorSpace,this.texture.generateMipmaps=e.generateMipmaps,this.texture.minFilter=e.minFilter,this.texture.magFilter=e.magFilter;const n={uniforms:{tEquirect:{value:null}},vertexShader:`

				varying vec3 vWorldDirection;

				vec3 transformDirection( in vec3 dir, in mat4 matrix ) {

					return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );

				}

				void main() {

					vWorldDirection = transformDirection( position, modelMatrix );

					#include <begin_vertex>
					#include <project_vertex>

				}
			`,fragmentShader:`

				uniform sampler2D tEquirect;

				varying vec3 vWorldDirection;

				#include <common>

				void main() {

					vec3 direction = normalize( vWorldDirection );

					vec2 sampleUV = equirectUv( direction );

					gl_FragColor = texture2D( tEquirect, sampleUV );

				}
			`},r=new fi(5,5,5),a=new hn({name:"CubemapFromEquirect",uniforms:jn(n.uniforms),vertexShader:n.vertexShader,fragmentShader:n.fragmentShader,side:xe,blending:on});a.uniforms.tEquirect.value=e;const o=new Ze(r,a),s=e.minFilter;return e.minFilter===si&&(e.minFilter=Re),new Gl(1,10,this).update(t,o),e.minFilter=s,o.geometry.dispose(),o.material.dispose(),this}clear(t,e,n,r){const a=t.getRenderTarget();for(let o=0;o<6;o++)t.setRenderTarget(this,o),t.clear(e,n,r);t.setRenderTarget(a)}}const br=new L,Wl=new L,Xl=new Ct;class xn{constructor(t=new L(1,0,0),e=0){this.isPlane=!0,this.normal=t,this.constant=e}set(t,e){return this.normal.copy(t),this.constant=e,this}setComponents(t,e,n,r){return this.normal.set(t,e,n),this.constant=r,this}setFromNormalAndCoplanarPoint(t,e){return this.normal.copy(t),this.constant=-e.dot(this.normal),this}setFromCoplanarPoints(t,e,n){const r=br.subVectors(n,e).cross(Wl.subVectors(t,e)).normalize();return this.setFromNormalAndCoplanarPoint(r,t),this}copy(t){return this.normal.copy(t.normal),this.constant=t.constant,this}normalize(){const t=1/this.normal.length();return this.normal.multiplyScalar(t),this.constant*=t,this}negate(){return this.constant*=-1,this.normal.negate(),this}distanceToPoint(t){return this.normal.dot(t)+this.constant}distanceToSphere(t){return this.distanceToPoint(t.center)-t.radius}projectPoint(t,e){return e.copy(t).addScaledVector(this.normal,-this.distanceToPoint(t))}intersectLine(t,e){const n=t.delta(br),r=this.normal.dot(n);if(r===0)return this.distanceToPoint(t.start)===0?e.copy(t.start):null;const a=-(t.start.dot(this.normal)+this.constant)/r;return a<0||a>1?null:e.copy(t.start).addScaledVector(n,a)}intersectsLine(t){const e=this.distanceToPoint(t.start),n=this.distanceToPoint(t.end);return e<0&&n>0||n<0&&e>0}intersectsBox(t){return t.intersectsPlane(this)}intersectsSphere(t){return t.intersectsPlane(this)}coplanarPoint(t){return t.copy(this.normal).multiplyScalar(-this.constant)}applyMatrix4(t,e){const n=e||Xl.getNormalMatrix(t),r=this.coplanarPoint(br).applyMatrix4(t),a=this.normal.applyMatrix3(n).normalize();return this.constant=-r.dot(a),this}translate(t){return this.constant-=t.dot(this.normal),this}equals(t){return t.normal.equals(this.normal)&&t.constant===this.constant}clone(){return new this.constructor().copy(this)}}const vn=new $r,Ni=new L;class Qs{constructor(t=new xn,e=new xn,n=new xn,r=new xn,a=new xn,o=new xn){this.planes=[t,e,n,r,a,o]}set(t,e,n,r,a,o){const s=this.planes;return s[0].copy(t),s[1].copy(e),s[2].copy(n),s[3].copy(r),s[4].copy(a),s[5].copy(o),this}copy(t){const e=this.planes;for(let n=0;n<6;n++)e[n].copy(t.planes[n]);return this}setFromProjectionMatrix(t,e=je){const n=this.planes,r=t.elements,a=r[0],o=r[1],s=r[2],l=r[3],c=r[4],u=r[5],d=r[6],f=r[7],m=r[8],v=r[9],_=r[10],p=r[11],h=r[12],E=r[13],T=r[14],b=r[15];if(n[0].setComponents(l-a,f-c,p-m,b-h).normalize(),n[1].setComponents(l+a,f+c,p+m,b+h).normalize(),n[2].setComponents(l+o,f+u,p+v,b+E).normalize(),n[3].setComponents(l-o,f-u,p-v,b-E).normalize(),n[4].setComponents(l-s,f-d,p-_,b-T).normalize(),e===je)n[5].setComponents(l+s,f+d,p+_,b+T).normalize();else if(e===Wi)n[5].setComponents(s,d,_,T).normalize();else throw new Error("THREE.Frustum.setFromProjectionMatrix(): Invalid coordinate system: "+e);return this}intersectsObject(t){if(t.boundingSphere!==void 0)t.boundingSphere===null&&t.computeBoundingSphere(),vn.copy(t.boundingSphere).applyMatrix4(t.matrixWorld);else{const e=t.geometry;e.boundingSphere===null&&e.computeBoundingSphere(),vn.copy(e.boundingSphere).applyMatrix4(t.matrixWorld)}return this.intersectsSphere(vn)}intersectsSprite(t){return vn.center.set(0,0,0),vn.radius=.7071067811865476,vn.applyMatrix4(t.matrixWorld),this.intersectsSphere(vn)}intersectsSphere(t){const e=this.planes,n=t.center,r=-t.radius;for(let a=0;a<6;a++)if(e[a].distanceToPoint(n)<r)return!1;return!0}intersectsBox(t){const e=this.planes;for(let n=0;n<6;n++){const r=e[n];if(Ni.x=r.normal.x>0?t.max.x:t.min.x,Ni.y=r.normal.y>0?t.max.y:t.min.y,Ni.z=r.normal.z>0?t.max.z:t.min.z,r.distanceToPoint(Ni)<0)return!1}return!0}containsPoint(t){const e=this.planes;for(let n=0;n<6;n++)if(e[n].distanceToPoint(t)<0)return!1;return!0}clone(){return new this.constructor().copy(this)}}function to(){let i=null,t=!1,e=null,n=null;function r(a,o){e(a,o),n=i.requestAnimationFrame(r)}return{start:function(){t!==!0&&e!==null&&(n=i.requestAnimationFrame(r),t=!0)},stop:function(){i.cancelAnimationFrame(n),t=!1},setAnimationLoop:function(a){e=a},setContext:function(a){i=a}}}function ql(i,t){const e=t.isWebGL2,n=new WeakMap;function r(c,u){const d=c.array,f=c.usage,m=d.byteLength,v=i.createBuffer();i.bindBuffer(u,v),i.bufferData(u,d,f),c.onUploadCallback();let _;if(d instanceof Float32Array)_=i.FLOAT;else if(d instanceof Uint16Array)if(c.isFloat16BufferAttribute)if(e)_=i.HALF_FLOAT;else throw new Error("THREE.WebGLAttributes: Usage of Float16BufferAttribute requires WebGL2.");else _=i.UNSIGNED_SHORT;else if(d instanceof Int16Array)_=i.SHORT;else if(d instanceof Uint32Array)_=i.UNSIGNED_INT;else if(d instanceof Int32Array)_=i.INT;else if(d instanceof Int8Array)_=i.BYTE;else if(d instanceof Uint8Array)_=i.UNSIGNED_BYTE;else if(d instanceof Uint8ClampedArray)_=i.UNSIGNED_BYTE;else throw new Error("THREE.WebGLAttributes: Unsupported buffer data format: "+d);return{buffer:v,type:_,bytesPerElement:d.BYTES_PER_ELEMENT,version:c.version,size:m}}function a(c,u,d){const f=u.array,m=u._updateRange,v=u.updateRanges;if(i.bindBuffer(d,c),m.count===-1&&v.length===0&&i.bufferSubData(d,0,f),v.length!==0){for(let _=0,p=v.length;_<p;_++){const h=v[_];e?i.bufferSubData(d,h.start*f.BYTES_PER_ELEMENT,f,h.start,h.count):i.bufferSubData(d,h.start*f.BYTES_PER_ELEMENT,f.subarray(h.start,h.start+h.count))}u.clearUpdateRanges()}m.count!==-1&&(e?i.bufferSubData(d,m.offset*f.BYTES_PER_ELEMENT,f,m.offset,m.count):i.bufferSubData(d,m.offset*f.BYTES_PER_ELEMENT,f.subarray(m.offset,m.offset+m.count)),m.count=-1),u.onUploadCallback()}function o(c){return c.isInterleavedBufferAttribute&&(c=c.data),n.get(c)}function s(c){c.isInterleavedBufferAttribute&&(c=c.data);const u=n.get(c);u&&(i.deleteBuffer(u.buffer),n.delete(c))}function l(c,u){if(c.isGLBufferAttribute){const f=n.get(c);(!f||f.version<c.version)&&n.set(c,{buffer:c.buffer,type:c.type,bytesPerElement:c.elementSize,version:c.version});return}c.isInterleavedBufferAttribute&&(c=c.data);const d=n.get(c);if(d===void 0)n.set(c,r(c,u));else if(d.version<c.version){if(d.size!==c.array.byteLength)throw new Error("THREE.WebGLAttributes: The size of the buffer attribute's array buffer does not match the original size. Resizing buffer attributes is not supported.");a(d.buffer,c,u),d.version=c.version}}return{get:o,remove:s,update:l}}class jr extends dn{constructor(t=1,e=1,n=1,r=1){super(),this.type="PlaneGeometry",this.parameters={width:t,height:e,widthSegments:n,heightSegments:r};const a=t/2,o=e/2,s=Math.floor(n),l=Math.floor(r),c=s+1,u=l+1,d=t/s,f=e/l,m=[],v=[],_=[],p=[];for(let h=0;h<u;h++){const E=h*f-o;for(let T=0;T<c;T++){const b=T*d-a;v.push(b,-E,0),_.push(0,0,1),p.push(T/s),p.push(1-h/l)}}for(let h=0;h<l;h++)for(let E=0;E<s;E++){const T=E+c*h,b=E+c*(h+1),D=E+1+c*(h+1),R=E+1+c*h;m.push(T,b,R),m.push(b,D,R)}this.setIndex(m),this.setAttribute("position",new Ke(v,3)),this.setAttribute("normal",new Ke(_,3)),this.setAttribute("uv",new Ke(p,2))}copy(t){return super.copy(t),this.parameters=Object.assign({},t.parameters),this}static fromJSON(t){return new jr(t.width,t.height,t.widthSegments,t.heightSegments)}}var Yl=`#ifdef USE_ALPHAHASH
	if ( diffuseColor.a < getAlphaHashThreshold( vPosition ) ) discard;
#endif`,$l=`#ifdef USE_ALPHAHASH
	const float ALPHA_HASH_SCALE = 0.05;
	float hash2D( vec2 value ) {
		return fract( 1.0e4 * sin( 17.0 * value.x + 0.1 * value.y ) * ( 0.1 + abs( sin( 13.0 * value.y + value.x ) ) ) );
	}
	float hash3D( vec3 value ) {
		return hash2D( vec2( hash2D( value.xy ), value.z ) );
	}
	float getAlphaHashThreshold( vec3 position ) {
		float maxDeriv = max(
			length( dFdx( position.xyz ) ),
			length( dFdy( position.xyz ) )
		);
		float pixScale = 1.0 / ( ALPHA_HASH_SCALE * maxDeriv );
		vec2 pixScales = vec2(
			exp2( floor( log2( pixScale ) ) ),
			exp2( ceil( log2( pixScale ) ) )
		);
		vec2 alpha = vec2(
			hash3D( floor( pixScales.x * position.xyz ) ),
			hash3D( floor( pixScales.y * position.xyz ) )
		);
		float lerpFactor = fract( log2( pixScale ) );
		float x = ( 1.0 - lerpFactor ) * alpha.x + lerpFactor * alpha.y;
		float a = min( lerpFactor, 1.0 - lerpFactor );
		vec3 cases = vec3(
			x * x / ( 2.0 * a * ( 1.0 - a ) ),
			( x - 0.5 * a ) / ( 1.0 - a ),
			1.0 - ( ( 1.0 - x ) * ( 1.0 - x ) / ( 2.0 * a * ( 1.0 - a ) ) )
		);
		float threshold = ( x < ( 1.0 - a ) )
			? ( ( x < a ) ? cases.x : cases.y )
			: cases.z;
		return clamp( threshold , 1.0e-6, 1.0 );
	}
#endif`,jl=`#ifdef USE_ALPHAMAP
	diffuseColor.a *= texture2D( alphaMap, vAlphaMapUv ).g;
#endif`,Zl=`#ifdef USE_ALPHAMAP
	uniform sampler2D alphaMap;
#endif`,Kl=`#ifdef USE_ALPHATEST
	if ( diffuseColor.a < alphaTest ) discard;
#endif`,Jl=`#ifdef USE_ALPHATEST
	uniform float alphaTest;
#endif`,Ql=`#ifdef USE_AOMAP
	float ambientOcclusion = ( texture2D( aoMap, vAoMapUv ).r - 1.0 ) * aoMapIntensity + 1.0;
	reflectedLight.indirectDiffuse *= ambientOcclusion;
	#if defined( USE_CLEARCOAT ) 
		clearcoatSpecularIndirect *= ambientOcclusion;
	#endif
	#if defined( USE_SHEEN ) 
		sheenSpecularIndirect *= ambientOcclusion;
	#endif
	#if defined( USE_ENVMAP ) && defined( STANDARD )
		float dotNV = saturate( dot( geometryNormal, geometryViewDir ) );
		reflectedLight.indirectSpecular *= computeSpecularOcclusion( dotNV, ambientOcclusion, material.roughness );
	#endif
#endif`,tc=`#ifdef USE_AOMAP
	uniform sampler2D aoMap;
	uniform float aoMapIntensity;
#endif`,ec=`#ifdef USE_BATCHING
	attribute float batchId;
	uniform highp sampler2D batchingTexture;
	mat4 getBatchingMatrix( const in float i ) {
		int size = textureSize( batchingTexture, 0 ).x;
		int j = int( i ) * 4;
		int x = j % size;
		int y = j / size;
		vec4 v1 = texelFetch( batchingTexture, ivec2( x, y ), 0 );
		vec4 v2 = texelFetch( batchingTexture, ivec2( x + 1, y ), 0 );
		vec4 v3 = texelFetch( batchingTexture, ivec2( x + 2, y ), 0 );
		vec4 v4 = texelFetch( batchingTexture, ivec2( x + 3, y ), 0 );
		return mat4( v1, v2, v3, v4 );
	}
#endif`,nc=`#ifdef USE_BATCHING
	mat4 batchingMatrix = getBatchingMatrix( batchId );
#endif`,ic=`vec3 transformed = vec3( position );
#ifdef USE_ALPHAHASH
	vPosition = vec3( position );
#endif`,rc=`vec3 objectNormal = vec3( normal );
#ifdef USE_TANGENT
	vec3 objectTangent = vec3( tangent.xyz );
#endif`,ac=`float G_BlinnPhong_Implicit( ) {
	return 0.25;
}
float D_BlinnPhong( const in float shininess, const in float dotNH ) {
	return RECIPROCAL_PI * ( shininess * 0.5 + 1.0 ) * pow( dotNH, shininess );
}
vec3 BRDF_BlinnPhong( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in vec3 specularColor, const in float shininess ) {
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNH = saturate( dot( normal, halfDir ) );
	float dotVH = saturate( dot( viewDir, halfDir ) );
	vec3 F = F_Schlick( specularColor, 1.0, dotVH );
	float G = G_BlinnPhong_Implicit( );
	float D = D_BlinnPhong( shininess, dotNH );
	return F * ( G * D );
} // validated`,sc=`#ifdef USE_IRIDESCENCE
	const mat3 XYZ_TO_REC709 = mat3(
		 3.2404542, -0.9692660,  0.0556434,
		-1.5371385,  1.8760108, -0.2040259,
		-0.4985314,  0.0415560,  1.0572252
	);
	vec3 Fresnel0ToIor( vec3 fresnel0 ) {
		vec3 sqrtF0 = sqrt( fresnel0 );
		return ( vec3( 1.0 ) + sqrtF0 ) / ( vec3( 1.0 ) - sqrtF0 );
	}
	vec3 IorToFresnel0( vec3 transmittedIor, float incidentIor ) {
		return pow2( ( transmittedIor - vec3( incidentIor ) ) / ( transmittedIor + vec3( incidentIor ) ) );
	}
	float IorToFresnel0( float transmittedIor, float incidentIor ) {
		return pow2( ( transmittedIor - incidentIor ) / ( transmittedIor + incidentIor ));
	}
	vec3 evalSensitivity( float OPD, vec3 shift ) {
		float phase = 2.0 * PI * OPD * 1.0e-9;
		vec3 val = vec3( 5.4856e-13, 4.4201e-13, 5.2481e-13 );
		vec3 pos = vec3( 1.6810e+06, 1.7953e+06, 2.2084e+06 );
		vec3 var = vec3( 4.3278e+09, 9.3046e+09, 6.6121e+09 );
		vec3 xyz = val * sqrt( 2.0 * PI * var ) * cos( pos * phase + shift ) * exp( - pow2( phase ) * var );
		xyz.x += 9.7470e-14 * sqrt( 2.0 * PI * 4.5282e+09 ) * cos( 2.2399e+06 * phase + shift[ 0 ] ) * exp( - 4.5282e+09 * pow2( phase ) );
		xyz /= 1.0685e-7;
		vec3 rgb = XYZ_TO_REC709 * xyz;
		return rgb;
	}
	vec3 evalIridescence( float outsideIOR, float eta2, float cosTheta1, float thinFilmThickness, vec3 baseF0 ) {
		vec3 I;
		float iridescenceIOR = mix( outsideIOR, eta2, smoothstep( 0.0, 0.03, thinFilmThickness ) );
		float sinTheta2Sq = pow2( outsideIOR / iridescenceIOR ) * ( 1.0 - pow2( cosTheta1 ) );
		float cosTheta2Sq = 1.0 - sinTheta2Sq;
		if ( cosTheta2Sq < 0.0 ) {
			return vec3( 1.0 );
		}
		float cosTheta2 = sqrt( cosTheta2Sq );
		float R0 = IorToFresnel0( iridescenceIOR, outsideIOR );
		float R12 = F_Schlick( R0, 1.0, cosTheta1 );
		float T121 = 1.0 - R12;
		float phi12 = 0.0;
		if ( iridescenceIOR < outsideIOR ) phi12 = PI;
		float phi21 = PI - phi12;
		vec3 baseIOR = Fresnel0ToIor( clamp( baseF0, 0.0, 0.9999 ) );		vec3 R1 = IorToFresnel0( baseIOR, iridescenceIOR );
		vec3 R23 = F_Schlick( R1, 1.0, cosTheta2 );
		vec3 phi23 = vec3( 0.0 );
		if ( baseIOR[ 0 ] < iridescenceIOR ) phi23[ 0 ] = PI;
		if ( baseIOR[ 1 ] < iridescenceIOR ) phi23[ 1 ] = PI;
		if ( baseIOR[ 2 ] < iridescenceIOR ) phi23[ 2 ] = PI;
		float OPD = 2.0 * iridescenceIOR * thinFilmThickness * cosTheta2;
		vec3 phi = vec3( phi21 ) + phi23;
		vec3 R123 = clamp( R12 * R23, 1e-5, 0.9999 );
		vec3 r123 = sqrt( R123 );
		vec3 Rs = pow2( T121 ) * R23 / ( vec3( 1.0 ) - R123 );
		vec3 C0 = R12 + Rs;
		I = C0;
		vec3 Cm = Rs - T121;
		for ( int m = 1; m <= 2; ++ m ) {
			Cm *= r123;
			vec3 Sm = 2.0 * evalSensitivity( float( m ) * OPD, float( m ) * phi );
			I += Cm * Sm;
		}
		return max( I, vec3( 0.0 ) );
	}
#endif`,oc=`#ifdef USE_BUMPMAP
	uniform sampler2D bumpMap;
	uniform float bumpScale;
	vec2 dHdxy_fwd() {
		vec2 dSTdx = dFdx( vBumpMapUv );
		vec2 dSTdy = dFdy( vBumpMapUv );
		float Hll = bumpScale * texture2D( bumpMap, vBumpMapUv ).x;
		float dBx = bumpScale * texture2D( bumpMap, vBumpMapUv + dSTdx ).x - Hll;
		float dBy = bumpScale * texture2D( bumpMap, vBumpMapUv + dSTdy ).x - Hll;
		return vec2( dBx, dBy );
	}
	vec3 perturbNormalArb( vec3 surf_pos, vec3 surf_norm, vec2 dHdxy, float faceDirection ) {
		vec3 vSigmaX = normalize( dFdx( surf_pos.xyz ) );
		vec3 vSigmaY = normalize( dFdy( surf_pos.xyz ) );
		vec3 vN = surf_norm;
		vec3 R1 = cross( vSigmaY, vN );
		vec3 R2 = cross( vN, vSigmaX );
		float fDet = dot( vSigmaX, R1 ) * faceDirection;
		vec3 vGrad = sign( fDet ) * ( dHdxy.x * R1 + dHdxy.y * R2 );
		return normalize( abs( fDet ) * surf_norm - vGrad );
	}
#endif`,lc=`#if NUM_CLIPPING_PLANES > 0
	vec4 plane;
	#pragma unroll_loop_start
	for ( int i = 0; i < UNION_CLIPPING_PLANES; i ++ ) {
		plane = clippingPlanes[ i ];
		if ( dot( vClipPosition, plane.xyz ) > plane.w ) discard;
	}
	#pragma unroll_loop_end
	#if UNION_CLIPPING_PLANES < NUM_CLIPPING_PLANES
		bool clipped = true;
		#pragma unroll_loop_start
		for ( int i = UNION_CLIPPING_PLANES; i < NUM_CLIPPING_PLANES; i ++ ) {
			plane = clippingPlanes[ i ];
			clipped = ( dot( vClipPosition, plane.xyz ) > plane.w ) && clipped;
		}
		#pragma unroll_loop_end
		if ( clipped ) discard;
	#endif
#endif`,cc=`#if NUM_CLIPPING_PLANES > 0
	varying vec3 vClipPosition;
	uniform vec4 clippingPlanes[ NUM_CLIPPING_PLANES ];
#endif`,uc=`#if NUM_CLIPPING_PLANES > 0
	varying vec3 vClipPosition;
#endif`,hc=`#if NUM_CLIPPING_PLANES > 0
	vClipPosition = - mvPosition.xyz;
#endif`,dc=`#if defined( USE_COLOR_ALPHA )
	diffuseColor *= vColor;
#elif defined( USE_COLOR )
	diffuseColor.rgb *= vColor;
#endif`,fc=`#if defined( USE_COLOR_ALPHA )
	varying vec4 vColor;
#elif defined( USE_COLOR )
	varying vec3 vColor;
#endif`,pc=`#if defined( USE_COLOR_ALPHA )
	varying vec4 vColor;
#elif defined( USE_COLOR ) || defined( USE_INSTANCING_COLOR )
	varying vec3 vColor;
#endif`,mc=`#if defined( USE_COLOR_ALPHA )
	vColor = vec4( 1.0 );
#elif defined( USE_COLOR ) || defined( USE_INSTANCING_COLOR )
	vColor = vec3( 1.0 );
#endif
#ifdef USE_COLOR
	vColor *= color;
#endif
#ifdef USE_INSTANCING_COLOR
	vColor.xyz *= instanceColor.xyz;
#endif`,gc=`#define PI 3.141592653589793
#define PI2 6.283185307179586
#define PI_HALF 1.5707963267948966
#define RECIPROCAL_PI 0.3183098861837907
#define RECIPROCAL_PI2 0.15915494309189535
#define EPSILON 1e-6
#ifndef saturate
#define saturate( a ) clamp( a, 0.0, 1.0 )
#endif
#define whiteComplement( a ) ( 1.0 - saturate( a ) )
float pow2( const in float x ) { return x*x; }
vec3 pow2( const in vec3 x ) { return x*x; }
float pow3( const in float x ) { return x*x*x; }
float pow4( const in float x ) { float x2 = x*x; return x2*x2; }
float max3( const in vec3 v ) { return max( max( v.x, v.y ), v.z ); }
float average( const in vec3 v ) { return dot( v, vec3( 0.3333333 ) ); }
highp float rand( const in vec2 uv ) {
	const highp float a = 12.9898, b = 78.233, c = 43758.5453;
	highp float dt = dot( uv.xy, vec2( a,b ) ), sn = mod( dt, PI );
	return fract( sin( sn ) * c );
}
#ifdef HIGH_PRECISION
	float precisionSafeLength( vec3 v ) { return length( v ); }
#else
	float precisionSafeLength( vec3 v ) {
		float maxComponent = max3( abs( v ) );
		return length( v / maxComponent ) * maxComponent;
	}
#endif
struct IncidentLight {
	vec3 color;
	vec3 direction;
	bool visible;
};
struct ReflectedLight {
	vec3 directDiffuse;
	vec3 directSpecular;
	vec3 indirectDiffuse;
	vec3 indirectSpecular;
};
#ifdef USE_ALPHAHASH
	varying vec3 vPosition;
#endif
vec3 transformDirection( in vec3 dir, in mat4 matrix ) {
	return normalize( ( matrix * vec4( dir, 0.0 ) ).xyz );
}
vec3 inverseTransformDirection( in vec3 dir, in mat4 matrix ) {
	return normalize( ( vec4( dir, 0.0 ) * matrix ).xyz );
}
mat3 transposeMat3( const in mat3 m ) {
	mat3 tmp;
	tmp[ 0 ] = vec3( m[ 0 ].x, m[ 1 ].x, m[ 2 ].x );
	tmp[ 1 ] = vec3( m[ 0 ].y, m[ 1 ].y, m[ 2 ].y );
	tmp[ 2 ] = vec3( m[ 0 ].z, m[ 1 ].z, m[ 2 ].z );
	return tmp;
}
float luminance( const in vec3 rgb ) {
	const vec3 weights = vec3( 0.2126729, 0.7151522, 0.0721750 );
	return dot( weights, rgb );
}
bool isPerspectiveMatrix( mat4 m ) {
	return m[ 2 ][ 3 ] == - 1.0;
}
vec2 equirectUv( in vec3 dir ) {
	float u = atan( dir.z, dir.x ) * RECIPROCAL_PI2 + 0.5;
	float v = asin( clamp( dir.y, - 1.0, 1.0 ) ) * RECIPROCAL_PI + 0.5;
	return vec2( u, v );
}
vec3 BRDF_Lambert( const in vec3 diffuseColor ) {
	return RECIPROCAL_PI * diffuseColor;
}
vec3 F_Schlick( const in vec3 f0, const in float f90, const in float dotVH ) {
	float fresnel = exp2( ( - 5.55473 * dotVH - 6.98316 ) * dotVH );
	return f0 * ( 1.0 - fresnel ) + ( f90 * fresnel );
}
float F_Schlick( const in float f0, const in float f90, const in float dotVH ) {
	float fresnel = exp2( ( - 5.55473 * dotVH - 6.98316 ) * dotVH );
	return f0 * ( 1.0 - fresnel ) + ( f90 * fresnel );
} // validated`,_c=`#ifdef ENVMAP_TYPE_CUBE_UV
	#define cubeUV_minMipLevel 4.0
	#define cubeUV_minTileSize 16.0
	float getFace( vec3 direction ) {
		vec3 absDirection = abs( direction );
		float face = - 1.0;
		if ( absDirection.x > absDirection.z ) {
			if ( absDirection.x > absDirection.y )
				face = direction.x > 0.0 ? 0.0 : 3.0;
			else
				face = direction.y > 0.0 ? 1.0 : 4.0;
		} else {
			if ( absDirection.z > absDirection.y )
				face = direction.z > 0.0 ? 2.0 : 5.0;
			else
				face = direction.y > 0.0 ? 1.0 : 4.0;
		}
		return face;
	}
	vec2 getUV( vec3 direction, float face ) {
		vec2 uv;
		if ( face == 0.0 ) {
			uv = vec2( direction.z, direction.y ) / abs( direction.x );
		} else if ( face == 1.0 ) {
			uv = vec2( - direction.x, - direction.z ) / abs( direction.y );
		} else if ( face == 2.0 ) {
			uv = vec2( - direction.x, direction.y ) / abs( direction.z );
		} else if ( face == 3.0 ) {
			uv = vec2( - direction.z, direction.y ) / abs( direction.x );
		} else if ( face == 4.0 ) {
			uv = vec2( - direction.x, direction.z ) / abs( direction.y );
		} else {
			uv = vec2( direction.x, direction.y ) / abs( direction.z );
		}
		return 0.5 * ( uv + 1.0 );
	}
	vec3 bilinearCubeUV( sampler2D envMap, vec3 direction, float mipInt ) {
		float face = getFace( direction );
		float filterInt = max( cubeUV_minMipLevel - mipInt, 0.0 );
		mipInt = max( mipInt, cubeUV_minMipLevel );
		float faceSize = exp2( mipInt );
		highp vec2 uv = getUV( direction, face ) * ( faceSize - 2.0 ) + 1.0;
		if ( face > 2.0 ) {
			uv.y += faceSize;
			face -= 3.0;
		}
		uv.x += face * faceSize;
		uv.x += filterInt * 3.0 * cubeUV_minTileSize;
		uv.y += 4.0 * ( exp2( CUBEUV_MAX_MIP ) - faceSize );
		uv.x *= CUBEUV_TEXEL_WIDTH;
		uv.y *= CUBEUV_TEXEL_HEIGHT;
		#ifdef texture2DGradEXT
			return texture2DGradEXT( envMap, uv, vec2( 0.0 ), vec2( 0.0 ) ).rgb;
		#else
			return texture2D( envMap, uv ).rgb;
		#endif
	}
	#define cubeUV_r0 1.0
	#define cubeUV_m0 - 2.0
	#define cubeUV_r1 0.8
	#define cubeUV_m1 - 1.0
	#define cubeUV_r4 0.4
	#define cubeUV_m4 2.0
	#define cubeUV_r5 0.305
	#define cubeUV_m5 3.0
	#define cubeUV_r6 0.21
	#define cubeUV_m6 4.0
	float roughnessToMip( float roughness ) {
		float mip = 0.0;
		if ( roughness >= cubeUV_r1 ) {
			mip = ( cubeUV_r0 - roughness ) * ( cubeUV_m1 - cubeUV_m0 ) / ( cubeUV_r0 - cubeUV_r1 ) + cubeUV_m0;
		} else if ( roughness >= cubeUV_r4 ) {
			mip = ( cubeUV_r1 - roughness ) * ( cubeUV_m4 - cubeUV_m1 ) / ( cubeUV_r1 - cubeUV_r4 ) + cubeUV_m1;
		} else if ( roughness >= cubeUV_r5 ) {
			mip = ( cubeUV_r4 - roughness ) * ( cubeUV_m5 - cubeUV_m4 ) / ( cubeUV_r4 - cubeUV_r5 ) + cubeUV_m4;
		} else if ( roughness >= cubeUV_r6 ) {
			mip = ( cubeUV_r5 - roughness ) * ( cubeUV_m6 - cubeUV_m5 ) / ( cubeUV_r5 - cubeUV_r6 ) + cubeUV_m5;
		} else {
			mip = - 2.0 * log2( 1.16 * roughness );		}
		return mip;
	}
	vec4 textureCubeUV( sampler2D envMap, vec3 sampleDir, float roughness ) {
		float mip = clamp( roughnessToMip( roughness ), cubeUV_m0, CUBEUV_MAX_MIP );
		float mipF = fract( mip );
		float mipInt = floor( mip );
		vec3 color0 = bilinearCubeUV( envMap, sampleDir, mipInt );
		if ( mipF == 0.0 ) {
			return vec4( color0, 1.0 );
		} else {
			vec3 color1 = bilinearCubeUV( envMap, sampleDir, mipInt + 1.0 );
			return vec4( mix( color0, color1, mipF ), 1.0 );
		}
	}
#endif`,vc=`vec3 transformedNormal = objectNormal;
#ifdef USE_TANGENT
	vec3 transformedTangent = objectTangent;
#endif
#ifdef USE_BATCHING
	mat3 bm = mat3( batchingMatrix );
	transformedNormal /= vec3( dot( bm[ 0 ], bm[ 0 ] ), dot( bm[ 1 ], bm[ 1 ] ), dot( bm[ 2 ], bm[ 2 ] ) );
	transformedNormal = bm * transformedNormal;
	#ifdef USE_TANGENT
		transformedTangent = bm * transformedTangent;
	#endif
#endif
#ifdef USE_INSTANCING
	mat3 im = mat3( instanceMatrix );
	transformedNormal /= vec3( dot( im[ 0 ], im[ 0 ] ), dot( im[ 1 ], im[ 1 ] ), dot( im[ 2 ], im[ 2 ] ) );
	transformedNormal = im * transformedNormal;
	#ifdef USE_TANGENT
		transformedTangent = im * transformedTangent;
	#endif
#endif
transformedNormal = normalMatrix * transformedNormal;
#ifdef FLIP_SIDED
	transformedNormal = - transformedNormal;
#endif
#ifdef USE_TANGENT
	transformedTangent = ( modelViewMatrix * vec4( transformedTangent, 0.0 ) ).xyz;
	#ifdef FLIP_SIDED
		transformedTangent = - transformedTangent;
	#endif
#endif`,xc=`#ifdef USE_DISPLACEMENTMAP
	uniform sampler2D displacementMap;
	uniform float displacementScale;
	uniform float displacementBias;
#endif`,Sc=`#ifdef USE_DISPLACEMENTMAP
	transformed += normalize( objectNormal ) * ( texture2D( displacementMap, vDisplacementMapUv ).x * displacementScale + displacementBias );
#endif`,yc=`#ifdef USE_EMISSIVEMAP
	vec4 emissiveColor = texture2D( emissiveMap, vEmissiveMapUv );
	totalEmissiveRadiance *= emissiveColor.rgb;
#endif`,Tc=`#ifdef USE_EMISSIVEMAP
	uniform sampler2D emissiveMap;
#endif`,Mc="gl_FragColor = linearToOutputTexel( gl_FragColor );",Ec=`
const mat3 LINEAR_SRGB_TO_LINEAR_DISPLAY_P3 = mat3(
	vec3( 0.8224621, 0.177538, 0.0 ),
	vec3( 0.0331941, 0.9668058, 0.0 ),
	vec3( 0.0170827, 0.0723974, 0.9105199 )
);
const mat3 LINEAR_DISPLAY_P3_TO_LINEAR_SRGB = mat3(
	vec3( 1.2249401, - 0.2249404, 0.0 ),
	vec3( - 0.0420569, 1.0420571, 0.0 ),
	vec3( - 0.0196376, - 0.0786361, 1.0982735 )
);
vec4 LinearSRGBToLinearDisplayP3( in vec4 value ) {
	return vec4( value.rgb * LINEAR_SRGB_TO_LINEAR_DISPLAY_P3, value.a );
}
vec4 LinearDisplayP3ToLinearSRGB( in vec4 value ) {
	return vec4( value.rgb * LINEAR_DISPLAY_P3_TO_LINEAR_SRGB, value.a );
}
vec4 LinearTransferOETF( in vec4 value ) {
	return value;
}
vec4 sRGBTransferOETF( in vec4 value ) {
	return vec4( mix( pow( value.rgb, vec3( 0.41666 ) ) * 1.055 - vec3( 0.055 ), value.rgb * 12.92, vec3( lessThanEqual( value.rgb, vec3( 0.0031308 ) ) ) ), value.a );
}
vec4 LinearToLinear( in vec4 value ) {
	return value;
}
vec4 LinearTosRGB( in vec4 value ) {
	return sRGBTransferOETF( value );
}`,bc=`#ifdef USE_ENVMAP
	#ifdef ENV_WORLDPOS
		vec3 cameraToFrag;
		if ( isOrthographic ) {
			cameraToFrag = normalize( vec3( - viewMatrix[ 0 ][ 2 ], - viewMatrix[ 1 ][ 2 ], - viewMatrix[ 2 ][ 2 ] ) );
		} else {
			cameraToFrag = normalize( vWorldPosition - cameraPosition );
		}
		vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );
		#ifdef ENVMAP_MODE_REFLECTION
			vec3 reflectVec = reflect( cameraToFrag, worldNormal );
		#else
			vec3 reflectVec = refract( cameraToFrag, worldNormal, refractionRatio );
		#endif
	#else
		vec3 reflectVec = vReflect;
	#endif
	#ifdef ENVMAP_TYPE_CUBE
		vec4 envColor = textureCube( envMap, vec3( flipEnvMap * reflectVec.x, reflectVec.yz ) );
	#else
		vec4 envColor = vec4( 0.0 );
	#endif
	#ifdef ENVMAP_BLENDING_MULTIPLY
		outgoingLight = mix( outgoingLight, outgoingLight * envColor.xyz, specularStrength * reflectivity );
	#elif defined( ENVMAP_BLENDING_MIX )
		outgoingLight = mix( outgoingLight, envColor.xyz, specularStrength * reflectivity );
	#elif defined( ENVMAP_BLENDING_ADD )
		outgoingLight += envColor.xyz * specularStrength * reflectivity;
	#endif
#endif`,Ac=`#ifdef USE_ENVMAP
	uniform float envMapIntensity;
	uniform float flipEnvMap;
	#ifdef ENVMAP_TYPE_CUBE
		uniform samplerCube envMap;
	#else
		uniform sampler2D envMap;
	#endif
	
#endif`,wc=`#ifdef USE_ENVMAP
	uniform float reflectivity;
	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( LAMBERT )
		#define ENV_WORLDPOS
	#endif
	#ifdef ENV_WORLDPOS
		varying vec3 vWorldPosition;
		uniform float refractionRatio;
	#else
		varying vec3 vReflect;
	#endif
#endif`,Rc=`#ifdef USE_ENVMAP
	#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( PHONG ) || defined( LAMBERT )
		#define ENV_WORLDPOS
	#endif
	#ifdef ENV_WORLDPOS
		
		varying vec3 vWorldPosition;
	#else
		varying vec3 vReflect;
		uniform float refractionRatio;
	#endif
#endif`,Cc=`#ifdef USE_ENVMAP
	#ifdef ENV_WORLDPOS
		vWorldPosition = worldPosition.xyz;
	#else
		vec3 cameraToVertex;
		if ( isOrthographic ) {
			cameraToVertex = normalize( vec3( - viewMatrix[ 0 ][ 2 ], - viewMatrix[ 1 ][ 2 ], - viewMatrix[ 2 ][ 2 ] ) );
		} else {
			cameraToVertex = normalize( worldPosition.xyz - cameraPosition );
		}
		vec3 worldNormal = inverseTransformDirection( transformedNormal, viewMatrix );
		#ifdef ENVMAP_MODE_REFLECTION
			vReflect = reflect( cameraToVertex, worldNormal );
		#else
			vReflect = refract( cameraToVertex, worldNormal, refractionRatio );
		#endif
	#endif
#endif`,Pc=`#ifdef USE_FOG
	vFogDepth = - mvPosition.z;
#endif`,Lc=`#ifdef USE_FOG
	varying float vFogDepth;
#endif`,Dc=`#ifdef USE_FOG
	#ifdef FOG_EXP2
		float fogFactor = 1.0 - exp( - fogDensity * fogDensity * vFogDepth * vFogDepth );
	#else
		float fogFactor = smoothstep( fogNear, fogFar, vFogDepth );
	#endif
	gl_FragColor.rgb = mix( gl_FragColor.rgb, fogColor, fogFactor );
#endif`,Uc=`#ifdef USE_FOG
	uniform vec3 fogColor;
	varying float vFogDepth;
	#ifdef FOG_EXP2
		uniform float fogDensity;
	#else
		uniform float fogNear;
		uniform float fogFar;
	#endif
#endif`,Ic=`#ifdef USE_GRADIENTMAP
	uniform sampler2D gradientMap;
#endif
vec3 getGradientIrradiance( vec3 normal, vec3 lightDirection ) {
	float dotNL = dot( normal, lightDirection );
	vec2 coord = vec2( dotNL * 0.5 + 0.5, 0.0 );
	#ifdef USE_GRADIENTMAP
		return vec3( texture2D( gradientMap, coord ).r );
	#else
		vec2 fw = fwidth( coord ) * 0.5;
		return mix( vec3( 0.7 ), vec3( 1.0 ), smoothstep( 0.7 - fw.x, 0.7 + fw.x, coord.x ) );
	#endif
}`,Nc=`#ifdef USE_LIGHTMAP
	vec4 lightMapTexel = texture2D( lightMap, vLightMapUv );
	vec3 lightMapIrradiance = lightMapTexel.rgb * lightMapIntensity;
	reflectedLight.indirectDiffuse += lightMapIrradiance;
#endif`,Fc=`#ifdef USE_LIGHTMAP
	uniform sampler2D lightMap;
	uniform float lightMapIntensity;
#endif`,Oc=`LambertMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.specularStrength = specularStrength;`,zc=`varying vec3 vViewPosition;
struct LambertMaterial {
	vec3 diffuseColor;
	float specularStrength;
};
void RE_Direct_Lambert( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in LambertMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectDiffuse_Lambert( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in LambertMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_Lambert
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Lambert`,Bc=`uniform bool receiveShadow;
uniform vec3 ambientLightColor;
#if defined( USE_LIGHT_PROBES )
	uniform vec3 lightProbe[ 9 ];
#endif
vec3 shGetIrradianceAt( in vec3 normal, in vec3 shCoefficients[ 9 ] ) {
	float x = normal.x, y = normal.y, z = normal.z;
	vec3 result = shCoefficients[ 0 ] * 0.886227;
	result += shCoefficients[ 1 ] * 2.0 * 0.511664 * y;
	result += shCoefficients[ 2 ] * 2.0 * 0.511664 * z;
	result += shCoefficients[ 3 ] * 2.0 * 0.511664 * x;
	result += shCoefficients[ 4 ] * 2.0 * 0.429043 * x * y;
	result += shCoefficients[ 5 ] * 2.0 * 0.429043 * y * z;
	result += shCoefficients[ 6 ] * ( 0.743125 * z * z - 0.247708 );
	result += shCoefficients[ 7 ] * 2.0 * 0.429043 * x * z;
	result += shCoefficients[ 8 ] * 0.429043 * ( x * x - y * y );
	return result;
}
vec3 getLightProbeIrradiance( const in vec3 lightProbe[ 9 ], const in vec3 normal ) {
	vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );
	vec3 irradiance = shGetIrradianceAt( worldNormal, lightProbe );
	return irradiance;
}
vec3 getAmbientLightIrradiance( const in vec3 ambientLightColor ) {
	vec3 irradiance = ambientLightColor;
	return irradiance;
}
float getDistanceAttenuation( const in float lightDistance, const in float cutoffDistance, const in float decayExponent ) {
	#if defined ( LEGACY_LIGHTS )
		if ( cutoffDistance > 0.0 && decayExponent > 0.0 ) {
			return pow( saturate( - lightDistance / cutoffDistance + 1.0 ), decayExponent );
		}
		return 1.0;
	#else
		float distanceFalloff = 1.0 / max( pow( lightDistance, decayExponent ), 0.01 );
		if ( cutoffDistance > 0.0 ) {
			distanceFalloff *= pow2( saturate( 1.0 - pow4( lightDistance / cutoffDistance ) ) );
		}
		return distanceFalloff;
	#endif
}
float getSpotAttenuation( const in float coneCosine, const in float penumbraCosine, const in float angleCosine ) {
	return smoothstep( coneCosine, penumbraCosine, angleCosine );
}
#if NUM_DIR_LIGHTS > 0
	struct DirectionalLight {
		vec3 direction;
		vec3 color;
	};
	uniform DirectionalLight directionalLights[ NUM_DIR_LIGHTS ];
	void getDirectionalLightInfo( const in DirectionalLight directionalLight, out IncidentLight light ) {
		light.color = directionalLight.color;
		light.direction = directionalLight.direction;
		light.visible = true;
	}
#endif
#if NUM_POINT_LIGHTS > 0
	struct PointLight {
		vec3 position;
		vec3 color;
		float distance;
		float decay;
	};
	uniform PointLight pointLights[ NUM_POINT_LIGHTS ];
	void getPointLightInfo( const in PointLight pointLight, const in vec3 geometryPosition, out IncidentLight light ) {
		vec3 lVector = pointLight.position - geometryPosition;
		light.direction = normalize( lVector );
		float lightDistance = length( lVector );
		light.color = pointLight.color;
		light.color *= getDistanceAttenuation( lightDistance, pointLight.distance, pointLight.decay );
		light.visible = ( light.color != vec3( 0.0 ) );
	}
#endif
#if NUM_SPOT_LIGHTS > 0
	struct SpotLight {
		vec3 position;
		vec3 direction;
		vec3 color;
		float distance;
		float decay;
		float coneCos;
		float penumbraCos;
	};
	uniform SpotLight spotLights[ NUM_SPOT_LIGHTS ];
	void getSpotLightInfo( const in SpotLight spotLight, const in vec3 geometryPosition, out IncidentLight light ) {
		vec3 lVector = spotLight.position - geometryPosition;
		light.direction = normalize( lVector );
		float angleCos = dot( light.direction, spotLight.direction );
		float spotAttenuation = getSpotAttenuation( spotLight.coneCos, spotLight.penumbraCos, angleCos );
		if ( spotAttenuation > 0.0 ) {
			float lightDistance = length( lVector );
			light.color = spotLight.color * spotAttenuation;
			light.color *= getDistanceAttenuation( lightDistance, spotLight.distance, spotLight.decay );
			light.visible = ( light.color != vec3( 0.0 ) );
		} else {
			light.color = vec3( 0.0 );
			light.visible = false;
		}
	}
#endif
#if NUM_RECT_AREA_LIGHTS > 0
	struct RectAreaLight {
		vec3 color;
		vec3 position;
		vec3 halfWidth;
		vec3 halfHeight;
	};
	uniform sampler2D ltc_1;	uniform sampler2D ltc_2;
	uniform RectAreaLight rectAreaLights[ NUM_RECT_AREA_LIGHTS ];
#endif
#if NUM_HEMI_LIGHTS > 0
	struct HemisphereLight {
		vec3 direction;
		vec3 skyColor;
		vec3 groundColor;
	};
	uniform HemisphereLight hemisphereLights[ NUM_HEMI_LIGHTS ];
	vec3 getHemisphereLightIrradiance( const in HemisphereLight hemiLight, const in vec3 normal ) {
		float dotNL = dot( normal, hemiLight.direction );
		float hemiDiffuseWeight = 0.5 * dotNL + 0.5;
		vec3 irradiance = mix( hemiLight.groundColor, hemiLight.skyColor, hemiDiffuseWeight );
		return irradiance;
	}
#endif`,Vc=`#ifdef USE_ENVMAP
	vec3 getIBLIrradiance( const in vec3 normal ) {
		#ifdef ENVMAP_TYPE_CUBE_UV
			vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );
			vec4 envMapColor = textureCubeUV( envMap, worldNormal, 1.0 );
			return PI * envMapColor.rgb * envMapIntensity;
		#else
			return vec3( 0.0 );
		#endif
	}
	vec3 getIBLRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness ) {
		#ifdef ENVMAP_TYPE_CUBE_UV
			vec3 reflectVec = reflect( - viewDir, normal );
			reflectVec = normalize( mix( reflectVec, normal, roughness * roughness) );
			reflectVec = inverseTransformDirection( reflectVec, viewMatrix );
			vec4 envMapColor = textureCubeUV( envMap, reflectVec, roughness );
			return envMapColor.rgb * envMapIntensity;
		#else
			return vec3( 0.0 );
		#endif
	}
	#ifdef USE_ANISOTROPY
		vec3 getIBLAnisotropyRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness, const in vec3 bitangent, const in float anisotropy ) {
			#ifdef ENVMAP_TYPE_CUBE_UV
				vec3 bentNormal = cross( bitangent, viewDir );
				bentNormal = normalize( cross( bentNormal, bitangent ) );
				bentNormal = normalize( mix( bentNormal, normal, pow2( pow2( 1.0 - anisotropy * ( 1.0 - roughness ) ) ) ) );
				return getIBLRadiance( viewDir, bentNormal, roughness );
			#else
				return vec3( 0.0 );
			#endif
		}
	#endif
#endif`,Hc=`ToonMaterial material;
material.diffuseColor = diffuseColor.rgb;`,Gc=`varying vec3 vViewPosition;
struct ToonMaterial {
	vec3 diffuseColor;
};
void RE_Direct_Toon( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in ToonMaterial material, inout ReflectedLight reflectedLight ) {
	vec3 irradiance = getGradientIrradiance( geometryNormal, directLight.direction ) * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectDiffuse_Toon( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in ToonMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_Toon
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Toon`,kc=`BlinnPhongMaterial material;
material.diffuseColor = diffuseColor.rgb;
material.specularColor = specular;
material.specularShininess = shininess;
material.specularStrength = specularStrength;`,Wc=`varying vec3 vViewPosition;
struct BlinnPhongMaterial {
	vec3 diffuseColor;
	vec3 specularColor;
	float specularShininess;
	float specularStrength;
};
void RE_Direct_BlinnPhong( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in BlinnPhongMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
	reflectedLight.directSpecular += irradiance * BRDF_BlinnPhong( directLight.direction, geometryViewDir, geometryNormal, material.specularColor, material.specularShininess ) * material.specularStrength;
}
void RE_IndirectDiffuse_BlinnPhong( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in BlinnPhongMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
#define RE_Direct				RE_Direct_BlinnPhong
#define RE_IndirectDiffuse		RE_IndirectDiffuse_BlinnPhong`,Xc=`PhysicalMaterial material;
material.diffuseColor = diffuseColor.rgb * ( 1.0 - metalnessFactor );
vec3 dxy = max( abs( dFdx( nonPerturbedNormal ) ), abs( dFdy( nonPerturbedNormal ) ) );
float geometryRoughness = max( max( dxy.x, dxy.y ), dxy.z );
material.roughness = max( roughnessFactor, 0.0525 );material.roughness += geometryRoughness;
material.roughness = min( material.roughness, 1.0 );
#ifdef IOR
	material.ior = ior;
	#ifdef USE_SPECULAR
		float specularIntensityFactor = specularIntensity;
		vec3 specularColorFactor = specularColor;
		#ifdef USE_SPECULAR_COLORMAP
			specularColorFactor *= texture2D( specularColorMap, vSpecularColorMapUv ).rgb;
		#endif
		#ifdef USE_SPECULAR_INTENSITYMAP
			specularIntensityFactor *= texture2D( specularIntensityMap, vSpecularIntensityMapUv ).a;
		#endif
		material.specularF90 = mix( specularIntensityFactor, 1.0, metalnessFactor );
	#else
		float specularIntensityFactor = 1.0;
		vec3 specularColorFactor = vec3( 1.0 );
		material.specularF90 = 1.0;
	#endif
	material.specularColor = mix( min( pow2( ( material.ior - 1.0 ) / ( material.ior + 1.0 ) ) * specularColorFactor, vec3( 1.0 ) ) * specularIntensityFactor, diffuseColor.rgb, metalnessFactor );
#else
	material.specularColor = mix( vec3( 0.04 ), diffuseColor.rgb, metalnessFactor );
	material.specularF90 = 1.0;
#endif
#ifdef USE_CLEARCOAT
	material.clearcoat = clearcoat;
	material.clearcoatRoughness = clearcoatRoughness;
	material.clearcoatF0 = vec3( 0.04 );
	material.clearcoatF90 = 1.0;
	#ifdef USE_CLEARCOATMAP
		material.clearcoat *= texture2D( clearcoatMap, vClearcoatMapUv ).x;
	#endif
	#ifdef USE_CLEARCOAT_ROUGHNESSMAP
		material.clearcoatRoughness *= texture2D( clearcoatRoughnessMap, vClearcoatRoughnessMapUv ).y;
	#endif
	material.clearcoat = saturate( material.clearcoat );	material.clearcoatRoughness = max( material.clearcoatRoughness, 0.0525 );
	material.clearcoatRoughness += geometryRoughness;
	material.clearcoatRoughness = min( material.clearcoatRoughness, 1.0 );
#endif
#ifdef USE_IRIDESCENCE
	material.iridescence = iridescence;
	material.iridescenceIOR = iridescenceIOR;
	#ifdef USE_IRIDESCENCEMAP
		material.iridescence *= texture2D( iridescenceMap, vIridescenceMapUv ).r;
	#endif
	#ifdef USE_IRIDESCENCE_THICKNESSMAP
		material.iridescenceThickness = (iridescenceThicknessMaximum - iridescenceThicknessMinimum) * texture2D( iridescenceThicknessMap, vIridescenceThicknessMapUv ).g + iridescenceThicknessMinimum;
	#else
		material.iridescenceThickness = iridescenceThicknessMaximum;
	#endif
#endif
#ifdef USE_SHEEN
	material.sheenColor = sheenColor;
	#ifdef USE_SHEEN_COLORMAP
		material.sheenColor *= texture2D( sheenColorMap, vSheenColorMapUv ).rgb;
	#endif
	material.sheenRoughness = clamp( sheenRoughness, 0.07, 1.0 );
	#ifdef USE_SHEEN_ROUGHNESSMAP
		material.sheenRoughness *= texture2D( sheenRoughnessMap, vSheenRoughnessMapUv ).a;
	#endif
#endif
#ifdef USE_ANISOTROPY
	#ifdef USE_ANISOTROPYMAP
		mat2 anisotropyMat = mat2( anisotropyVector.x, anisotropyVector.y, - anisotropyVector.y, anisotropyVector.x );
		vec3 anisotropyPolar = texture2D( anisotropyMap, vAnisotropyMapUv ).rgb;
		vec2 anisotropyV = anisotropyMat * normalize( 2.0 * anisotropyPolar.rg - vec2( 1.0 ) ) * anisotropyPolar.b;
	#else
		vec2 anisotropyV = anisotropyVector;
	#endif
	material.anisotropy = length( anisotropyV );
	if( material.anisotropy == 0.0 ) {
		anisotropyV = vec2( 1.0, 0.0 );
	} else {
		anisotropyV /= material.anisotropy;
		material.anisotropy = saturate( material.anisotropy );
	}
	material.alphaT = mix( pow2( material.roughness ), 1.0, pow2( material.anisotropy ) );
	material.anisotropyT = tbn[ 0 ] * anisotropyV.x + tbn[ 1 ] * anisotropyV.y;
	material.anisotropyB = tbn[ 1 ] * anisotropyV.x - tbn[ 0 ] * anisotropyV.y;
#endif`,qc=`struct PhysicalMaterial {
	vec3 diffuseColor;
	float roughness;
	vec3 specularColor;
	float specularF90;
	#ifdef USE_CLEARCOAT
		float clearcoat;
		float clearcoatRoughness;
		vec3 clearcoatF0;
		float clearcoatF90;
	#endif
	#ifdef USE_IRIDESCENCE
		float iridescence;
		float iridescenceIOR;
		float iridescenceThickness;
		vec3 iridescenceFresnel;
		vec3 iridescenceF0;
	#endif
	#ifdef USE_SHEEN
		vec3 sheenColor;
		float sheenRoughness;
	#endif
	#ifdef IOR
		float ior;
	#endif
	#ifdef USE_TRANSMISSION
		float transmission;
		float transmissionAlpha;
		float thickness;
		float attenuationDistance;
		vec3 attenuationColor;
	#endif
	#ifdef USE_ANISOTROPY
		float anisotropy;
		float alphaT;
		vec3 anisotropyT;
		vec3 anisotropyB;
	#endif
};
vec3 clearcoatSpecularDirect = vec3( 0.0 );
vec3 clearcoatSpecularIndirect = vec3( 0.0 );
vec3 sheenSpecularDirect = vec3( 0.0 );
vec3 sheenSpecularIndirect = vec3(0.0 );
vec3 Schlick_to_F0( const in vec3 f, const in float f90, const in float dotVH ) {
    float x = clamp( 1.0 - dotVH, 0.0, 1.0 );
    float x2 = x * x;
    float x5 = clamp( x * x2 * x2, 0.0, 0.9999 );
    return ( f - vec3( f90 ) * x5 ) / ( 1.0 - x5 );
}
float V_GGX_SmithCorrelated( const in float alpha, const in float dotNL, const in float dotNV ) {
	float a2 = pow2( alpha );
	float gv = dotNL * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNV ) );
	float gl = dotNV * sqrt( a2 + ( 1.0 - a2 ) * pow2( dotNL ) );
	return 0.5 / max( gv + gl, EPSILON );
}
float D_GGX( const in float alpha, const in float dotNH ) {
	float a2 = pow2( alpha );
	float denom = pow2( dotNH ) * ( a2 - 1.0 ) + 1.0;
	return RECIPROCAL_PI * a2 / pow2( denom );
}
#ifdef USE_ANISOTROPY
	float V_GGX_SmithCorrelated_Anisotropic( const in float alphaT, const in float alphaB, const in float dotTV, const in float dotBV, const in float dotTL, const in float dotBL, const in float dotNV, const in float dotNL ) {
		float gv = dotNL * length( vec3( alphaT * dotTV, alphaB * dotBV, dotNV ) );
		float gl = dotNV * length( vec3( alphaT * dotTL, alphaB * dotBL, dotNL ) );
		float v = 0.5 / ( gv + gl );
		return saturate(v);
	}
	float D_GGX_Anisotropic( const in float alphaT, const in float alphaB, const in float dotNH, const in float dotTH, const in float dotBH ) {
		float a2 = alphaT * alphaB;
		highp vec3 v = vec3( alphaB * dotTH, alphaT * dotBH, a2 * dotNH );
		highp float v2 = dot( v, v );
		float w2 = a2 / v2;
		return RECIPROCAL_PI * a2 * pow2 ( w2 );
	}
#endif
#ifdef USE_CLEARCOAT
	vec3 BRDF_GGX_Clearcoat( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in PhysicalMaterial material) {
		vec3 f0 = material.clearcoatF0;
		float f90 = material.clearcoatF90;
		float roughness = material.clearcoatRoughness;
		float alpha = pow2( roughness );
		vec3 halfDir = normalize( lightDir + viewDir );
		float dotNL = saturate( dot( normal, lightDir ) );
		float dotNV = saturate( dot( normal, viewDir ) );
		float dotNH = saturate( dot( normal, halfDir ) );
		float dotVH = saturate( dot( viewDir, halfDir ) );
		vec3 F = F_Schlick( f0, f90, dotVH );
		float V = V_GGX_SmithCorrelated( alpha, dotNL, dotNV );
		float D = D_GGX( alpha, dotNH );
		return F * ( V * D );
	}
#endif
vec3 BRDF_GGX( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, const in PhysicalMaterial material ) {
	vec3 f0 = material.specularColor;
	float f90 = material.specularF90;
	float roughness = material.roughness;
	float alpha = pow2( roughness );
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNL = saturate( dot( normal, lightDir ) );
	float dotNV = saturate( dot( normal, viewDir ) );
	float dotNH = saturate( dot( normal, halfDir ) );
	float dotVH = saturate( dot( viewDir, halfDir ) );
	vec3 F = F_Schlick( f0, f90, dotVH );
	#ifdef USE_IRIDESCENCE
		F = mix( F, material.iridescenceFresnel, material.iridescence );
	#endif
	#ifdef USE_ANISOTROPY
		float dotTL = dot( material.anisotropyT, lightDir );
		float dotTV = dot( material.anisotropyT, viewDir );
		float dotTH = dot( material.anisotropyT, halfDir );
		float dotBL = dot( material.anisotropyB, lightDir );
		float dotBV = dot( material.anisotropyB, viewDir );
		float dotBH = dot( material.anisotropyB, halfDir );
		float V = V_GGX_SmithCorrelated_Anisotropic( material.alphaT, alpha, dotTV, dotBV, dotTL, dotBL, dotNV, dotNL );
		float D = D_GGX_Anisotropic( material.alphaT, alpha, dotNH, dotTH, dotBH );
	#else
		float V = V_GGX_SmithCorrelated( alpha, dotNL, dotNV );
		float D = D_GGX( alpha, dotNH );
	#endif
	return F * ( V * D );
}
vec2 LTC_Uv( const in vec3 N, const in vec3 V, const in float roughness ) {
	const float LUT_SIZE = 64.0;
	const float LUT_SCALE = ( LUT_SIZE - 1.0 ) / LUT_SIZE;
	const float LUT_BIAS = 0.5 / LUT_SIZE;
	float dotNV = saturate( dot( N, V ) );
	vec2 uv = vec2( roughness, sqrt( 1.0 - dotNV ) );
	uv = uv * LUT_SCALE + LUT_BIAS;
	return uv;
}
float LTC_ClippedSphereFormFactor( const in vec3 f ) {
	float l = length( f );
	return max( ( l * l + f.z ) / ( l + 1.0 ), 0.0 );
}
vec3 LTC_EdgeVectorFormFactor( const in vec3 v1, const in vec3 v2 ) {
	float x = dot( v1, v2 );
	float y = abs( x );
	float a = 0.8543985 + ( 0.4965155 + 0.0145206 * y ) * y;
	float b = 3.4175940 + ( 4.1616724 + y ) * y;
	float v = a / b;
	float theta_sintheta = ( x > 0.0 ) ? v : 0.5 * inversesqrt( max( 1.0 - x * x, 1e-7 ) ) - v;
	return cross( v1, v2 ) * theta_sintheta;
}
vec3 LTC_Evaluate( const in vec3 N, const in vec3 V, const in vec3 P, const in mat3 mInv, const in vec3 rectCoords[ 4 ] ) {
	vec3 v1 = rectCoords[ 1 ] - rectCoords[ 0 ];
	vec3 v2 = rectCoords[ 3 ] - rectCoords[ 0 ];
	vec3 lightNormal = cross( v1, v2 );
	if( dot( lightNormal, P - rectCoords[ 0 ] ) < 0.0 ) return vec3( 0.0 );
	vec3 T1, T2;
	T1 = normalize( V - N * dot( V, N ) );
	T2 = - cross( N, T1 );
	mat3 mat = mInv * transposeMat3( mat3( T1, T2, N ) );
	vec3 coords[ 4 ];
	coords[ 0 ] = mat * ( rectCoords[ 0 ] - P );
	coords[ 1 ] = mat * ( rectCoords[ 1 ] - P );
	coords[ 2 ] = mat * ( rectCoords[ 2 ] - P );
	coords[ 3 ] = mat * ( rectCoords[ 3 ] - P );
	coords[ 0 ] = normalize( coords[ 0 ] );
	coords[ 1 ] = normalize( coords[ 1 ] );
	coords[ 2 ] = normalize( coords[ 2 ] );
	coords[ 3 ] = normalize( coords[ 3 ] );
	vec3 vectorFormFactor = vec3( 0.0 );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 0 ], coords[ 1 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 1 ], coords[ 2 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 2 ], coords[ 3 ] );
	vectorFormFactor += LTC_EdgeVectorFormFactor( coords[ 3 ], coords[ 0 ] );
	float result = LTC_ClippedSphereFormFactor( vectorFormFactor );
	return vec3( result );
}
#if defined( USE_SHEEN )
float D_Charlie( float roughness, float dotNH ) {
	float alpha = pow2( roughness );
	float invAlpha = 1.0 / alpha;
	float cos2h = dotNH * dotNH;
	float sin2h = max( 1.0 - cos2h, 0.0078125 );
	return ( 2.0 + invAlpha ) * pow( sin2h, invAlpha * 0.5 ) / ( 2.0 * PI );
}
float V_Neubelt( float dotNV, float dotNL ) {
	return saturate( 1.0 / ( 4.0 * ( dotNL + dotNV - dotNL * dotNV ) ) );
}
vec3 BRDF_Sheen( const in vec3 lightDir, const in vec3 viewDir, const in vec3 normal, vec3 sheenColor, const in float sheenRoughness ) {
	vec3 halfDir = normalize( lightDir + viewDir );
	float dotNL = saturate( dot( normal, lightDir ) );
	float dotNV = saturate( dot( normal, viewDir ) );
	float dotNH = saturate( dot( normal, halfDir ) );
	float D = D_Charlie( sheenRoughness, dotNH );
	float V = V_Neubelt( dotNV, dotNL );
	return sheenColor * ( D * V );
}
#endif
float IBLSheenBRDF( const in vec3 normal, const in vec3 viewDir, const in float roughness ) {
	float dotNV = saturate( dot( normal, viewDir ) );
	float r2 = roughness * roughness;
	float a = roughness < 0.25 ? -339.2 * r2 + 161.4 * roughness - 25.9 : -8.48 * r2 + 14.3 * roughness - 9.95;
	float b = roughness < 0.25 ? 44.0 * r2 - 23.7 * roughness + 3.26 : 1.97 * r2 - 3.27 * roughness + 0.72;
	float DG = exp( a * dotNV + b ) + ( roughness < 0.25 ? 0.0 : 0.1 * ( roughness - 0.25 ) );
	return saturate( DG * RECIPROCAL_PI );
}
vec2 DFGApprox( const in vec3 normal, const in vec3 viewDir, const in float roughness ) {
	float dotNV = saturate( dot( normal, viewDir ) );
	const vec4 c0 = vec4( - 1, - 0.0275, - 0.572, 0.022 );
	const vec4 c1 = vec4( 1, 0.0425, 1.04, - 0.04 );
	vec4 r = roughness * c0 + c1;
	float a004 = min( r.x * r.x, exp2( - 9.28 * dotNV ) ) * r.x + r.y;
	vec2 fab = vec2( - 1.04, 1.04 ) * a004 + r.zw;
	return fab;
}
vec3 EnvironmentBRDF( const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float roughness ) {
	vec2 fab = DFGApprox( normal, viewDir, roughness );
	return specularColor * fab.x + specularF90 * fab.y;
}
#ifdef USE_IRIDESCENCE
void computeMultiscatteringIridescence( const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float iridescence, const in vec3 iridescenceF0, const in float roughness, inout vec3 singleScatter, inout vec3 multiScatter ) {
#else
void computeMultiscattering( const in vec3 normal, const in vec3 viewDir, const in vec3 specularColor, const in float specularF90, const in float roughness, inout vec3 singleScatter, inout vec3 multiScatter ) {
#endif
	vec2 fab = DFGApprox( normal, viewDir, roughness );
	#ifdef USE_IRIDESCENCE
		vec3 Fr = mix( specularColor, iridescenceF0, iridescence );
	#else
		vec3 Fr = specularColor;
	#endif
	vec3 FssEss = Fr * fab.x + specularF90 * fab.y;
	float Ess = fab.x + fab.y;
	float Ems = 1.0 - Ess;
	vec3 Favg = Fr + ( 1.0 - Fr ) * 0.047619;	vec3 Fms = FssEss * Favg / ( 1.0 - Ems * Favg );
	singleScatter += FssEss;
	multiScatter += Fms * Ems;
}
#if NUM_RECT_AREA_LIGHTS > 0
	void RE_Direct_RectArea_Physical( const in RectAreaLight rectAreaLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
		vec3 normal = geometryNormal;
		vec3 viewDir = geometryViewDir;
		vec3 position = geometryPosition;
		vec3 lightPos = rectAreaLight.position;
		vec3 halfWidth = rectAreaLight.halfWidth;
		vec3 halfHeight = rectAreaLight.halfHeight;
		vec3 lightColor = rectAreaLight.color;
		float roughness = material.roughness;
		vec3 rectCoords[ 4 ];
		rectCoords[ 0 ] = lightPos + halfWidth - halfHeight;		rectCoords[ 1 ] = lightPos - halfWidth - halfHeight;
		rectCoords[ 2 ] = lightPos - halfWidth + halfHeight;
		rectCoords[ 3 ] = lightPos + halfWidth + halfHeight;
		vec2 uv = LTC_Uv( normal, viewDir, roughness );
		vec4 t1 = texture2D( ltc_1, uv );
		vec4 t2 = texture2D( ltc_2, uv );
		mat3 mInv = mat3(
			vec3( t1.x, 0, t1.y ),
			vec3(    0, 1,    0 ),
			vec3( t1.z, 0, t1.w )
		);
		vec3 fresnel = ( material.specularColor * t2.x + ( vec3( 1.0 ) - material.specularColor ) * t2.y );
		reflectedLight.directSpecular += lightColor * fresnel * LTC_Evaluate( normal, viewDir, position, mInv, rectCoords );
		reflectedLight.directDiffuse += lightColor * material.diffuseColor * LTC_Evaluate( normal, viewDir, position, mat3( 1.0 ), rectCoords );
	}
#endif
void RE_Direct_Physical( const in IncidentLight directLight, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
	float dotNL = saturate( dot( geometryNormal, directLight.direction ) );
	vec3 irradiance = dotNL * directLight.color;
	#ifdef USE_CLEARCOAT
		float dotNLcc = saturate( dot( geometryClearcoatNormal, directLight.direction ) );
		vec3 ccIrradiance = dotNLcc * directLight.color;
		clearcoatSpecularDirect += ccIrradiance * BRDF_GGX_Clearcoat( directLight.direction, geometryViewDir, geometryClearcoatNormal, material );
	#endif
	#ifdef USE_SHEEN
		sheenSpecularDirect += irradiance * BRDF_Sheen( directLight.direction, geometryViewDir, geometryNormal, material.sheenColor, material.sheenRoughness );
	#endif
	reflectedLight.directSpecular += irradiance * BRDF_GGX( directLight.direction, geometryViewDir, geometryNormal, material );
	reflectedLight.directDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectDiffuse_Physical( const in vec3 irradiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight ) {
	reflectedLight.indirectDiffuse += irradiance * BRDF_Lambert( material.diffuseColor );
}
void RE_IndirectSpecular_Physical( const in vec3 radiance, const in vec3 irradiance, const in vec3 clearcoatRadiance, const in vec3 geometryPosition, const in vec3 geometryNormal, const in vec3 geometryViewDir, const in vec3 geometryClearcoatNormal, const in PhysicalMaterial material, inout ReflectedLight reflectedLight) {
	#ifdef USE_CLEARCOAT
		clearcoatSpecularIndirect += clearcoatRadiance * EnvironmentBRDF( geometryClearcoatNormal, geometryViewDir, material.clearcoatF0, material.clearcoatF90, material.clearcoatRoughness );
	#endif
	#ifdef USE_SHEEN
		sheenSpecularIndirect += irradiance * material.sheenColor * IBLSheenBRDF( geometryNormal, geometryViewDir, material.sheenRoughness );
	#endif
	vec3 singleScattering = vec3( 0.0 );
	vec3 multiScattering = vec3( 0.0 );
	vec3 cosineWeightedIrradiance = irradiance * RECIPROCAL_PI;
	#ifdef USE_IRIDESCENCE
		computeMultiscatteringIridescence( geometryNormal, geometryViewDir, material.specularColor, material.specularF90, material.iridescence, material.iridescenceFresnel, material.roughness, singleScattering, multiScattering );
	#else
		computeMultiscattering( geometryNormal, geometryViewDir, material.specularColor, material.specularF90, material.roughness, singleScattering, multiScattering );
	#endif
	vec3 totalScattering = singleScattering + multiScattering;
	vec3 diffuse = material.diffuseColor * ( 1.0 - max( max( totalScattering.r, totalScattering.g ), totalScattering.b ) );
	reflectedLight.indirectSpecular += radiance * singleScattering;
	reflectedLight.indirectSpecular += multiScattering * cosineWeightedIrradiance;
	reflectedLight.indirectDiffuse += diffuse * cosineWeightedIrradiance;
}
#define RE_Direct				RE_Direct_Physical
#define RE_Direct_RectArea		RE_Direct_RectArea_Physical
#define RE_IndirectDiffuse		RE_IndirectDiffuse_Physical
#define RE_IndirectSpecular		RE_IndirectSpecular_Physical
float computeSpecularOcclusion( const in float dotNV, const in float ambientOcclusion, const in float roughness ) {
	return saturate( pow( dotNV + ambientOcclusion, exp2( - 16.0 * roughness - 1.0 ) ) - 1.0 + ambientOcclusion );
}`,Yc=`
vec3 geometryPosition = - vViewPosition;
vec3 geometryNormal = normal;
vec3 geometryViewDir = ( isOrthographic ) ? vec3( 0, 0, 1 ) : normalize( vViewPosition );
vec3 geometryClearcoatNormal = vec3( 0.0 );
#ifdef USE_CLEARCOAT
	geometryClearcoatNormal = clearcoatNormal;
#endif
#ifdef USE_IRIDESCENCE
	float dotNVi = saturate( dot( normal, geometryViewDir ) );
	if ( material.iridescenceThickness == 0.0 ) {
		material.iridescence = 0.0;
	} else {
		material.iridescence = saturate( material.iridescence );
	}
	if ( material.iridescence > 0.0 ) {
		material.iridescenceFresnel = evalIridescence( 1.0, material.iridescenceIOR, dotNVi, material.iridescenceThickness, material.specularColor );
		material.iridescenceF0 = Schlick_to_F0( material.iridescenceFresnel, 1.0, dotNVi );
	}
#endif
IncidentLight directLight;
#if ( NUM_POINT_LIGHTS > 0 ) && defined( RE_Direct )
	PointLight pointLight;
	#if defined( USE_SHADOWMAP ) && NUM_POINT_LIGHT_SHADOWS > 0
	PointLightShadow pointLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_POINT_LIGHTS; i ++ ) {
		pointLight = pointLights[ i ];
		getPointLightInfo( pointLight, geometryPosition, directLight );
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_POINT_LIGHT_SHADOWS )
		pointLightShadow = pointLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getPointShadow( pointShadowMap[ i ], pointLightShadow.shadowMapSize, pointLightShadow.shadowBias, pointLightShadow.shadowRadius, vPointShadowCoord[ i ], pointLightShadow.shadowCameraNear, pointLightShadow.shadowCameraFar ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_SPOT_LIGHTS > 0 ) && defined( RE_Direct )
	SpotLight spotLight;
	vec4 spotColor;
	vec3 spotLightCoord;
	bool inSpotLightMap;
	#if defined( USE_SHADOWMAP ) && NUM_SPOT_LIGHT_SHADOWS > 0
	SpotLightShadow spotLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHTS; i ++ ) {
		spotLight = spotLights[ i ];
		getSpotLightInfo( spotLight, geometryPosition, directLight );
		#if ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS )
		#define SPOT_LIGHT_MAP_INDEX UNROLLED_LOOP_INDEX
		#elif ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
		#define SPOT_LIGHT_MAP_INDEX NUM_SPOT_LIGHT_MAPS
		#else
		#define SPOT_LIGHT_MAP_INDEX ( UNROLLED_LOOP_INDEX - NUM_SPOT_LIGHT_SHADOWS + NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS )
		#endif
		#if ( SPOT_LIGHT_MAP_INDEX < NUM_SPOT_LIGHT_MAPS )
			spotLightCoord = vSpotLightCoord[ i ].xyz / vSpotLightCoord[ i ].w;
			inSpotLightMap = all( lessThan( abs( spotLightCoord * 2. - 1. ), vec3( 1.0 ) ) );
			spotColor = texture2D( spotLightMap[ SPOT_LIGHT_MAP_INDEX ], spotLightCoord.xy );
			directLight.color = inSpotLightMap ? directLight.color * spotColor.rgb : directLight.color;
		#endif
		#undef SPOT_LIGHT_MAP_INDEX
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
		spotLightShadow = spotLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getShadow( spotShadowMap[ i ], spotLightShadow.shadowMapSize, spotLightShadow.shadowBias, spotLightShadow.shadowRadius, vSpotLightCoord[ i ] ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_DIR_LIGHTS > 0 ) && defined( RE_Direct )
	DirectionalLight directionalLight;
	#if defined( USE_SHADOWMAP ) && NUM_DIR_LIGHT_SHADOWS > 0
	DirectionalLightShadow directionalLightShadow;
	#endif
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_DIR_LIGHTS; i ++ ) {
		directionalLight = directionalLights[ i ];
		getDirectionalLightInfo( directionalLight, directLight );
		#if defined( USE_SHADOWMAP ) && ( UNROLLED_LOOP_INDEX < NUM_DIR_LIGHT_SHADOWS )
		directionalLightShadow = directionalLightShadows[ i ];
		directLight.color *= ( directLight.visible && receiveShadow ) ? getShadow( directionalShadowMap[ i ], directionalLightShadow.shadowMapSize, directionalLightShadow.shadowBias, directionalLightShadow.shadowRadius, vDirectionalShadowCoord[ i ] ) : 1.0;
		#endif
		RE_Direct( directLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if ( NUM_RECT_AREA_LIGHTS > 0 ) && defined( RE_Direct_RectArea )
	RectAreaLight rectAreaLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_RECT_AREA_LIGHTS; i ++ ) {
		rectAreaLight = rectAreaLights[ i ];
		RE_Direct_RectArea( rectAreaLight, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
	}
	#pragma unroll_loop_end
#endif
#if defined( RE_IndirectDiffuse )
	vec3 iblIrradiance = vec3( 0.0 );
	vec3 irradiance = getAmbientLightIrradiance( ambientLightColor );
	#if defined( USE_LIGHT_PROBES )
		irradiance += getLightProbeIrradiance( lightProbe, geometryNormal );
	#endif
	#if ( NUM_HEMI_LIGHTS > 0 )
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_HEMI_LIGHTS; i ++ ) {
			irradiance += getHemisphereLightIrradiance( hemisphereLights[ i ], geometryNormal );
		}
		#pragma unroll_loop_end
	#endif
#endif
#if defined( RE_IndirectSpecular )
	vec3 radiance = vec3( 0.0 );
	vec3 clearcoatRadiance = vec3( 0.0 );
#endif`,$c=`#if defined( RE_IndirectDiffuse )
	#ifdef USE_LIGHTMAP
		vec4 lightMapTexel = texture2D( lightMap, vLightMapUv );
		vec3 lightMapIrradiance = lightMapTexel.rgb * lightMapIntensity;
		irradiance += lightMapIrradiance;
	#endif
	#if defined( USE_ENVMAP ) && defined( STANDARD ) && defined( ENVMAP_TYPE_CUBE_UV )
		iblIrradiance += getIBLIrradiance( geometryNormal );
	#endif
#endif
#if defined( USE_ENVMAP ) && defined( RE_IndirectSpecular )
	#ifdef USE_ANISOTROPY
		radiance += getIBLAnisotropyRadiance( geometryViewDir, geometryNormal, material.roughness, material.anisotropyB, material.anisotropy );
	#else
		radiance += getIBLRadiance( geometryViewDir, geometryNormal, material.roughness );
	#endif
	#ifdef USE_CLEARCOAT
		clearcoatRadiance += getIBLRadiance( geometryViewDir, geometryClearcoatNormal, material.clearcoatRoughness );
	#endif
#endif`,jc=`#if defined( RE_IndirectDiffuse )
	RE_IndirectDiffuse( irradiance, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
#endif
#if defined( RE_IndirectSpecular )
	RE_IndirectSpecular( radiance, iblIrradiance, clearcoatRadiance, geometryPosition, geometryNormal, geometryViewDir, geometryClearcoatNormal, material, reflectedLight );
#endif`,Zc=`#if defined( USE_LOGDEPTHBUF ) && defined( USE_LOGDEPTHBUF_EXT )
	gl_FragDepthEXT = vIsPerspective == 0.0 ? gl_FragCoord.z : log2( vFragDepth ) * logDepthBufFC * 0.5;
#endif`,Kc=`#if defined( USE_LOGDEPTHBUF ) && defined( USE_LOGDEPTHBUF_EXT )
	uniform float logDepthBufFC;
	varying float vFragDepth;
	varying float vIsPerspective;
#endif`,Jc=`#ifdef USE_LOGDEPTHBUF
	#ifdef USE_LOGDEPTHBUF_EXT
		varying float vFragDepth;
		varying float vIsPerspective;
	#else
		uniform float logDepthBufFC;
	#endif
#endif`,Qc=`#ifdef USE_LOGDEPTHBUF
	#ifdef USE_LOGDEPTHBUF_EXT
		vFragDepth = 1.0 + gl_Position.w;
		vIsPerspective = float( isPerspectiveMatrix( projectionMatrix ) );
	#else
		if ( isPerspectiveMatrix( projectionMatrix ) ) {
			gl_Position.z = log2( max( EPSILON, gl_Position.w + 1.0 ) ) * logDepthBufFC - 1.0;
			gl_Position.z *= gl_Position.w;
		}
	#endif
#endif`,tu=`#ifdef USE_MAP
	vec4 sampledDiffuseColor = texture2D( map, vMapUv );
	#ifdef DECODE_VIDEO_TEXTURE
		sampledDiffuseColor = vec4( mix( pow( sampledDiffuseColor.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), sampledDiffuseColor.rgb * 0.0773993808, vec3( lessThanEqual( sampledDiffuseColor.rgb, vec3( 0.04045 ) ) ) ), sampledDiffuseColor.w );
	
	#endif
	diffuseColor *= sampledDiffuseColor;
#endif`,eu=`#ifdef USE_MAP
	uniform sampler2D map;
#endif`,nu=`#if defined( USE_MAP ) || defined( USE_ALPHAMAP )
	#if defined( USE_POINTS_UV )
		vec2 uv = vUv;
	#else
		vec2 uv = ( uvTransform * vec3( gl_PointCoord.x, 1.0 - gl_PointCoord.y, 1 ) ).xy;
	#endif
#endif
#ifdef USE_MAP
	diffuseColor *= texture2D( map, uv );
#endif
#ifdef USE_ALPHAMAP
	diffuseColor.a *= texture2D( alphaMap, uv ).g;
#endif`,iu=`#if defined( USE_POINTS_UV )
	varying vec2 vUv;
#else
	#if defined( USE_MAP ) || defined( USE_ALPHAMAP )
		uniform mat3 uvTransform;
	#endif
#endif
#ifdef USE_MAP
	uniform sampler2D map;
#endif
#ifdef USE_ALPHAMAP
	uniform sampler2D alphaMap;
#endif`,ru=`float metalnessFactor = metalness;
#ifdef USE_METALNESSMAP
	vec4 texelMetalness = texture2D( metalnessMap, vMetalnessMapUv );
	metalnessFactor *= texelMetalness.b;
#endif`,au=`#ifdef USE_METALNESSMAP
	uniform sampler2D metalnessMap;
#endif`,su=`#if defined( USE_MORPHCOLORS ) && defined( MORPHTARGETS_TEXTURE )
	vColor *= morphTargetBaseInfluence;
	for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
		#if defined( USE_COLOR_ALPHA )
			if ( morphTargetInfluences[ i ] != 0.0 ) vColor += getMorph( gl_VertexID, i, 2 ) * morphTargetInfluences[ i ];
		#elif defined( USE_COLOR )
			if ( morphTargetInfluences[ i ] != 0.0 ) vColor += getMorph( gl_VertexID, i, 2 ).rgb * morphTargetInfluences[ i ];
		#endif
	}
#endif`,ou=`#ifdef USE_MORPHNORMALS
	objectNormal *= morphTargetBaseInfluence;
	#ifdef MORPHTARGETS_TEXTURE
		for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
			if ( morphTargetInfluences[ i ] != 0.0 ) objectNormal += getMorph( gl_VertexID, i, 1 ).xyz * morphTargetInfluences[ i ];
		}
	#else
		objectNormal += morphNormal0 * morphTargetInfluences[ 0 ];
		objectNormal += morphNormal1 * morphTargetInfluences[ 1 ];
		objectNormal += morphNormal2 * morphTargetInfluences[ 2 ];
		objectNormal += morphNormal3 * morphTargetInfluences[ 3 ];
	#endif
#endif`,lu=`#ifdef USE_MORPHTARGETS
	uniform float morphTargetBaseInfluence;
	#ifdef MORPHTARGETS_TEXTURE
		uniform float morphTargetInfluences[ MORPHTARGETS_COUNT ];
		uniform sampler2DArray morphTargetsTexture;
		uniform ivec2 morphTargetsTextureSize;
		vec4 getMorph( const in int vertexIndex, const in int morphTargetIndex, const in int offset ) {
			int texelIndex = vertexIndex * MORPHTARGETS_TEXTURE_STRIDE + offset;
			int y = texelIndex / morphTargetsTextureSize.x;
			int x = texelIndex - y * morphTargetsTextureSize.x;
			ivec3 morphUV = ivec3( x, y, morphTargetIndex );
			return texelFetch( morphTargetsTexture, morphUV, 0 );
		}
	#else
		#ifndef USE_MORPHNORMALS
			uniform float morphTargetInfluences[ 8 ];
		#else
			uniform float morphTargetInfluences[ 4 ];
		#endif
	#endif
#endif`,cu=`#ifdef USE_MORPHTARGETS
	transformed *= morphTargetBaseInfluence;
	#ifdef MORPHTARGETS_TEXTURE
		for ( int i = 0; i < MORPHTARGETS_COUNT; i ++ ) {
			if ( morphTargetInfluences[ i ] != 0.0 ) transformed += getMorph( gl_VertexID, i, 0 ).xyz * morphTargetInfluences[ i ];
		}
	#else
		transformed += morphTarget0 * morphTargetInfluences[ 0 ];
		transformed += morphTarget1 * morphTargetInfluences[ 1 ];
		transformed += morphTarget2 * morphTargetInfluences[ 2 ];
		transformed += morphTarget3 * morphTargetInfluences[ 3 ];
		#ifndef USE_MORPHNORMALS
			transformed += morphTarget4 * morphTargetInfluences[ 4 ];
			transformed += morphTarget5 * morphTargetInfluences[ 5 ];
			transformed += morphTarget6 * morphTargetInfluences[ 6 ];
			transformed += morphTarget7 * morphTargetInfluences[ 7 ];
		#endif
	#endif
#endif`,uu=`float faceDirection = gl_FrontFacing ? 1.0 : - 1.0;
#ifdef FLAT_SHADED
	vec3 fdx = dFdx( vViewPosition );
	vec3 fdy = dFdy( vViewPosition );
	vec3 normal = normalize( cross( fdx, fdy ) );
#else
	vec3 normal = normalize( vNormal );
	#ifdef DOUBLE_SIDED
		normal *= faceDirection;
	#endif
#endif
#if defined( USE_NORMALMAP_TANGENTSPACE ) || defined( USE_CLEARCOAT_NORMALMAP ) || defined( USE_ANISOTROPY )
	#ifdef USE_TANGENT
		mat3 tbn = mat3( normalize( vTangent ), normalize( vBitangent ), normal );
	#else
		mat3 tbn = getTangentFrame( - vViewPosition, normal,
		#if defined( USE_NORMALMAP )
			vNormalMapUv
		#elif defined( USE_CLEARCOAT_NORMALMAP )
			vClearcoatNormalMapUv
		#else
			vUv
		#endif
		);
	#endif
	#if defined( DOUBLE_SIDED ) && ! defined( FLAT_SHADED )
		tbn[0] *= faceDirection;
		tbn[1] *= faceDirection;
	#endif
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	#ifdef USE_TANGENT
		mat3 tbn2 = mat3( normalize( vTangent ), normalize( vBitangent ), normal );
	#else
		mat3 tbn2 = getTangentFrame( - vViewPosition, normal, vClearcoatNormalMapUv );
	#endif
	#if defined( DOUBLE_SIDED ) && ! defined( FLAT_SHADED )
		tbn2[0] *= faceDirection;
		tbn2[1] *= faceDirection;
	#endif
#endif
vec3 nonPerturbedNormal = normal;`,hu=`#ifdef USE_NORMALMAP_OBJECTSPACE
	normal = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0;
	#ifdef FLIP_SIDED
		normal = - normal;
	#endif
	#ifdef DOUBLE_SIDED
		normal = normal * faceDirection;
	#endif
	normal = normalize( normalMatrix * normal );
#elif defined( USE_NORMALMAP_TANGENTSPACE )
	vec3 mapN = texture2D( normalMap, vNormalMapUv ).xyz * 2.0 - 1.0;
	mapN.xy *= normalScale;
	normal = normalize( tbn * mapN );
#elif defined( USE_BUMPMAP )
	normal = perturbNormalArb( - vViewPosition, normal, dHdxy_fwd(), faceDirection );
#endif`,du=`#ifndef FLAT_SHADED
	varying vec3 vNormal;
	#ifdef USE_TANGENT
		varying vec3 vTangent;
		varying vec3 vBitangent;
	#endif
#endif`,fu=`#ifndef FLAT_SHADED
	varying vec3 vNormal;
	#ifdef USE_TANGENT
		varying vec3 vTangent;
		varying vec3 vBitangent;
	#endif
#endif`,pu=`#ifndef FLAT_SHADED
	vNormal = normalize( transformedNormal );
	#ifdef USE_TANGENT
		vTangent = normalize( transformedTangent );
		vBitangent = normalize( cross( vNormal, vTangent ) * tangent.w );
	#endif
#endif`,mu=`#ifdef USE_NORMALMAP
	uniform sampler2D normalMap;
	uniform vec2 normalScale;
#endif
#ifdef USE_NORMALMAP_OBJECTSPACE
	uniform mat3 normalMatrix;
#endif
#if ! defined ( USE_TANGENT ) && ( defined ( USE_NORMALMAP_TANGENTSPACE ) || defined ( USE_CLEARCOAT_NORMALMAP ) || defined( USE_ANISOTROPY ) )
	mat3 getTangentFrame( vec3 eye_pos, vec3 surf_norm, vec2 uv ) {
		vec3 q0 = dFdx( eye_pos.xyz );
		vec3 q1 = dFdy( eye_pos.xyz );
		vec2 st0 = dFdx( uv.st );
		vec2 st1 = dFdy( uv.st );
		vec3 N = surf_norm;
		vec3 q1perp = cross( q1, N );
		vec3 q0perp = cross( N, q0 );
		vec3 T = q1perp * st0.x + q0perp * st1.x;
		vec3 B = q1perp * st0.y + q0perp * st1.y;
		float det = max( dot( T, T ), dot( B, B ) );
		float scale = ( det == 0.0 ) ? 0.0 : inversesqrt( det );
		return mat3( T * scale, B * scale, N );
	}
#endif`,gu=`#ifdef USE_CLEARCOAT
	vec3 clearcoatNormal = nonPerturbedNormal;
#endif`,_u=`#ifdef USE_CLEARCOAT_NORMALMAP
	vec3 clearcoatMapN = texture2D( clearcoatNormalMap, vClearcoatNormalMapUv ).xyz * 2.0 - 1.0;
	clearcoatMapN.xy *= clearcoatNormalScale;
	clearcoatNormal = normalize( tbn2 * clearcoatMapN );
#endif`,vu=`#ifdef USE_CLEARCOATMAP
	uniform sampler2D clearcoatMap;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	uniform sampler2D clearcoatNormalMap;
	uniform vec2 clearcoatNormalScale;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	uniform sampler2D clearcoatRoughnessMap;
#endif`,xu=`#ifdef USE_IRIDESCENCEMAP
	uniform sampler2D iridescenceMap;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	uniform sampler2D iridescenceThicknessMap;
#endif`,Su=`#ifdef OPAQUE
diffuseColor.a = 1.0;
#endif
#ifdef USE_TRANSMISSION
diffuseColor.a *= material.transmissionAlpha;
#endif
gl_FragColor = vec4( outgoingLight, diffuseColor.a );`,yu=`vec3 packNormalToRGB( const in vec3 normal ) {
	return normalize( normal ) * 0.5 + 0.5;
}
vec3 unpackRGBToNormal( const in vec3 rgb ) {
	return 2.0 * rgb.xyz - 1.0;
}
const float PackUpscale = 256. / 255.;const float UnpackDownscale = 255. / 256.;
const vec3 PackFactors = vec3( 256. * 256. * 256., 256. * 256., 256. );
const vec4 UnpackFactors = UnpackDownscale / vec4( PackFactors, 1. );
const float ShiftRight8 = 1. / 256.;
vec4 packDepthToRGBA( const in float v ) {
	vec4 r = vec4( fract( v * PackFactors ), v );
	r.yzw -= r.xyz * ShiftRight8;	return r * PackUpscale;
}
float unpackRGBAToDepth( const in vec4 v ) {
	return dot( v, UnpackFactors );
}
vec2 packDepthToRG( in highp float v ) {
	return packDepthToRGBA( v ).yx;
}
float unpackRGToDepth( const in highp vec2 v ) {
	return unpackRGBAToDepth( vec4( v.xy, 0.0, 0.0 ) );
}
vec4 pack2HalfToRGBA( vec2 v ) {
	vec4 r = vec4( v.x, fract( v.x * 255.0 ), v.y, fract( v.y * 255.0 ) );
	return vec4( r.x - r.y / 255.0, r.y, r.z - r.w / 255.0, r.w );
}
vec2 unpackRGBATo2Half( vec4 v ) {
	return vec2( v.x + ( v.y / 255.0 ), v.z + ( v.w / 255.0 ) );
}
float viewZToOrthographicDepth( const in float viewZ, const in float near, const in float far ) {
	return ( viewZ + near ) / ( near - far );
}
float orthographicDepthToViewZ( const in float depth, const in float near, const in float far ) {
	return depth * ( near - far ) - near;
}
float viewZToPerspectiveDepth( const in float viewZ, const in float near, const in float far ) {
	return ( ( near + viewZ ) * far ) / ( ( far - near ) * viewZ );
}
float perspectiveDepthToViewZ( const in float depth, const in float near, const in float far ) {
	return ( near * far ) / ( ( far - near ) * depth - far );
}`,Tu=`#ifdef PREMULTIPLIED_ALPHA
	gl_FragColor.rgb *= gl_FragColor.a;
#endif`,Mu=`vec4 mvPosition = vec4( transformed, 1.0 );
#ifdef USE_BATCHING
	mvPosition = batchingMatrix * mvPosition;
#endif
#ifdef USE_INSTANCING
	mvPosition = instanceMatrix * mvPosition;
#endif
mvPosition = modelViewMatrix * mvPosition;
gl_Position = projectionMatrix * mvPosition;`,Eu=`#ifdef DITHERING
	gl_FragColor.rgb = dithering( gl_FragColor.rgb );
#endif`,bu=`#ifdef DITHERING
	vec3 dithering( vec3 color ) {
		float grid_position = rand( gl_FragCoord.xy );
		vec3 dither_shift_RGB = vec3( 0.25 / 255.0, -0.25 / 255.0, 0.25 / 255.0 );
		dither_shift_RGB = mix( 2.0 * dither_shift_RGB, -2.0 * dither_shift_RGB, grid_position );
		return color + dither_shift_RGB;
	}
#endif`,Au=`float roughnessFactor = roughness;
#ifdef USE_ROUGHNESSMAP
	vec4 texelRoughness = texture2D( roughnessMap, vRoughnessMapUv );
	roughnessFactor *= texelRoughness.g;
#endif`,wu=`#ifdef USE_ROUGHNESSMAP
	uniform sampler2D roughnessMap;
#endif`,Ru=`#if NUM_SPOT_LIGHT_COORDS > 0
	varying vec4 vSpotLightCoord[ NUM_SPOT_LIGHT_COORDS ];
#endif
#if NUM_SPOT_LIGHT_MAPS > 0
	uniform sampler2D spotLightMap[ NUM_SPOT_LIGHT_MAPS ];
#endif
#ifdef USE_SHADOWMAP
	#if NUM_DIR_LIGHT_SHADOWS > 0
		uniform sampler2D directionalShadowMap[ NUM_DIR_LIGHT_SHADOWS ];
		varying vec4 vDirectionalShadowCoord[ NUM_DIR_LIGHT_SHADOWS ];
		struct DirectionalLightShadow {
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform DirectionalLightShadow directionalLightShadows[ NUM_DIR_LIGHT_SHADOWS ];
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
		uniform sampler2D spotShadowMap[ NUM_SPOT_LIGHT_SHADOWS ];
		struct SpotLightShadow {
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform SpotLightShadow spotLightShadows[ NUM_SPOT_LIGHT_SHADOWS ];
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		uniform sampler2D pointShadowMap[ NUM_POINT_LIGHT_SHADOWS ];
		varying vec4 vPointShadowCoord[ NUM_POINT_LIGHT_SHADOWS ];
		struct PointLightShadow {
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
			float shadowCameraNear;
			float shadowCameraFar;
		};
		uniform PointLightShadow pointLightShadows[ NUM_POINT_LIGHT_SHADOWS ];
	#endif
	float texture2DCompare( sampler2D depths, vec2 uv, float compare ) {
		return step( compare, unpackRGBAToDepth( texture2D( depths, uv ) ) );
	}
	vec2 texture2DDistribution( sampler2D shadow, vec2 uv ) {
		return unpackRGBATo2Half( texture2D( shadow, uv ) );
	}
	float VSMShadow (sampler2D shadow, vec2 uv, float compare ){
		float occlusion = 1.0;
		vec2 distribution = texture2DDistribution( shadow, uv );
		float hard_shadow = step( compare , distribution.x );
		if (hard_shadow != 1.0 ) {
			float distance = compare - distribution.x ;
			float variance = max( 0.00000, distribution.y * distribution.y );
			float softness_probability = variance / (variance + distance * distance );			softness_probability = clamp( ( softness_probability - 0.3 ) / ( 0.95 - 0.3 ), 0.0, 1.0 );			occlusion = clamp( max( hard_shadow, softness_probability ), 0.0, 1.0 );
		}
		return occlusion;
	}
	float getShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowBias, float shadowRadius, vec4 shadowCoord ) {
		float shadow = 1.0;
		shadowCoord.xyz /= shadowCoord.w;
		shadowCoord.z += shadowBias;
		bool inFrustum = shadowCoord.x >= 0.0 && shadowCoord.x <= 1.0 && shadowCoord.y >= 0.0 && shadowCoord.y <= 1.0;
		bool frustumTest = inFrustum && shadowCoord.z <= 1.0;
		if ( frustumTest ) {
		#if defined( SHADOWMAP_TYPE_PCF )
			vec2 texelSize = vec2( 1.0 ) / shadowMapSize;
			float dx0 = - texelSize.x * shadowRadius;
			float dy0 = - texelSize.y * shadowRadius;
			float dx1 = + texelSize.x * shadowRadius;
			float dy1 = + texelSize.y * shadowRadius;
			float dx2 = dx0 / 2.0;
			float dy2 = dy0 / 2.0;
			float dx3 = dx1 / 2.0;
			float dy3 = dy1 / 2.0;
			shadow = (
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, dy0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, dy0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx2, dy2 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy2 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx3, dy2 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx2, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy, shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx3, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx2, dy3 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy3 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx3, dy3 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx0, dy1 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( 0.0, dy1 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, shadowCoord.xy + vec2( dx1, dy1 ), shadowCoord.z )
			) * ( 1.0 / 17.0 );
		#elif defined( SHADOWMAP_TYPE_PCF_SOFT )
			vec2 texelSize = vec2( 1.0 ) / shadowMapSize;
			float dx = texelSize.x;
			float dy = texelSize.y;
			vec2 uv = shadowCoord.xy;
			vec2 f = fract( uv * shadowMapSize + 0.5 );
			uv -= f * texelSize;
			shadow = (
				texture2DCompare( shadowMap, uv, shadowCoord.z ) +
				texture2DCompare( shadowMap, uv + vec2( dx, 0.0 ), shadowCoord.z ) +
				texture2DCompare( shadowMap, uv + vec2( 0.0, dy ), shadowCoord.z ) +
				texture2DCompare( shadowMap, uv + texelSize, shadowCoord.z ) +
				mix( texture2DCompare( shadowMap, uv + vec2( -dx, 0.0 ), shadowCoord.z ),
					 texture2DCompare( shadowMap, uv + vec2( 2.0 * dx, 0.0 ), shadowCoord.z ),
					 f.x ) +
				mix( texture2DCompare( shadowMap, uv + vec2( -dx, dy ), shadowCoord.z ),
					 texture2DCompare( shadowMap, uv + vec2( 2.0 * dx, dy ), shadowCoord.z ),
					 f.x ) +
				mix( texture2DCompare( shadowMap, uv + vec2( 0.0, -dy ), shadowCoord.z ),
					 texture2DCompare( shadowMap, uv + vec2( 0.0, 2.0 * dy ), shadowCoord.z ),
					 f.y ) +
				mix( texture2DCompare( shadowMap, uv + vec2( dx, -dy ), shadowCoord.z ),
					 texture2DCompare( shadowMap, uv + vec2( dx, 2.0 * dy ), shadowCoord.z ),
					 f.y ) +
				mix( mix( texture2DCompare( shadowMap, uv + vec2( -dx, -dy ), shadowCoord.z ),
						  texture2DCompare( shadowMap, uv + vec2( 2.0 * dx, -dy ), shadowCoord.z ),
						  f.x ),
					 mix( texture2DCompare( shadowMap, uv + vec2( -dx, 2.0 * dy ), shadowCoord.z ),
						  texture2DCompare( shadowMap, uv + vec2( 2.0 * dx, 2.0 * dy ), shadowCoord.z ),
						  f.x ),
					 f.y )
			) * ( 1.0 / 9.0 );
		#elif defined( SHADOWMAP_TYPE_VSM )
			shadow = VSMShadow( shadowMap, shadowCoord.xy, shadowCoord.z );
		#else
			shadow = texture2DCompare( shadowMap, shadowCoord.xy, shadowCoord.z );
		#endif
		}
		return shadow;
	}
	vec2 cubeToUV( vec3 v, float texelSizeY ) {
		vec3 absV = abs( v );
		float scaleToCube = 1.0 / max( absV.x, max( absV.y, absV.z ) );
		absV *= scaleToCube;
		v *= scaleToCube * ( 1.0 - 2.0 * texelSizeY );
		vec2 planar = v.xy;
		float almostATexel = 1.5 * texelSizeY;
		float almostOne = 1.0 - almostATexel;
		if ( absV.z >= almostOne ) {
			if ( v.z > 0.0 )
				planar.x = 4.0 - v.x;
		} else if ( absV.x >= almostOne ) {
			float signX = sign( v.x );
			planar.x = v.z * signX + 2.0 * signX;
		} else if ( absV.y >= almostOne ) {
			float signY = sign( v.y );
			planar.x = v.x + 2.0 * signY + 2.0;
			planar.y = v.z * signY - 2.0;
		}
		return vec2( 0.125, 0.25 ) * planar + vec2( 0.375, 0.75 );
	}
	float getPointShadow( sampler2D shadowMap, vec2 shadowMapSize, float shadowBias, float shadowRadius, vec4 shadowCoord, float shadowCameraNear, float shadowCameraFar ) {
		vec2 texelSize = vec2( 1.0 ) / ( shadowMapSize * vec2( 4.0, 2.0 ) );
		vec3 lightToPosition = shadowCoord.xyz;
		float dp = ( length( lightToPosition ) - shadowCameraNear ) / ( shadowCameraFar - shadowCameraNear );		dp += shadowBias;
		vec3 bd3D = normalize( lightToPosition );
		#if defined( SHADOWMAP_TYPE_PCF ) || defined( SHADOWMAP_TYPE_PCF_SOFT ) || defined( SHADOWMAP_TYPE_VSM )
			vec2 offset = vec2( - 1, 1 ) * shadowRadius * texelSize.y;
			return (
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xyy, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yyy, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xyx, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yyx, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xxy, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yxy, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.xxx, texelSize.y ), dp ) +
				texture2DCompare( shadowMap, cubeToUV( bd3D + offset.yxx, texelSize.y ), dp )
			) * ( 1.0 / 9.0 );
		#else
			return texture2DCompare( shadowMap, cubeToUV( bd3D, texelSize.y ), dp );
		#endif
	}
#endif`,Cu=`#if NUM_SPOT_LIGHT_COORDS > 0
	uniform mat4 spotLightMatrix[ NUM_SPOT_LIGHT_COORDS ];
	varying vec4 vSpotLightCoord[ NUM_SPOT_LIGHT_COORDS ];
#endif
#ifdef USE_SHADOWMAP
	#if NUM_DIR_LIGHT_SHADOWS > 0
		uniform mat4 directionalShadowMatrix[ NUM_DIR_LIGHT_SHADOWS ];
		varying vec4 vDirectionalShadowCoord[ NUM_DIR_LIGHT_SHADOWS ];
		struct DirectionalLightShadow {
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform DirectionalLightShadow directionalLightShadows[ NUM_DIR_LIGHT_SHADOWS ];
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
		struct SpotLightShadow {
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
		};
		uniform SpotLightShadow spotLightShadows[ NUM_SPOT_LIGHT_SHADOWS ];
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		uniform mat4 pointShadowMatrix[ NUM_POINT_LIGHT_SHADOWS ];
		varying vec4 vPointShadowCoord[ NUM_POINT_LIGHT_SHADOWS ];
		struct PointLightShadow {
			float shadowBias;
			float shadowNormalBias;
			float shadowRadius;
			vec2 shadowMapSize;
			float shadowCameraNear;
			float shadowCameraFar;
		};
		uniform PointLightShadow pointLightShadows[ NUM_POINT_LIGHT_SHADOWS ];
	#endif
#endif`,Pu=`#if ( defined( USE_SHADOWMAP ) && ( NUM_DIR_LIGHT_SHADOWS > 0 || NUM_POINT_LIGHT_SHADOWS > 0 ) ) || ( NUM_SPOT_LIGHT_COORDS > 0 )
	vec3 shadowWorldNormal = inverseTransformDirection( transformedNormal, viewMatrix );
	vec4 shadowWorldPosition;
#endif
#if defined( USE_SHADOWMAP )
	#if NUM_DIR_LIGHT_SHADOWS > 0
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_DIR_LIGHT_SHADOWS; i ++ ) {
			shadowWorldPosition = worldPosition + vec4( shadowWorldNormal * directionalLightShadows[ i ].shadowNormalBias, 0 );
			vDirectionalShadowCoord[ i ] = directionalShadowMatrix[ i ] * shadowWorldPosition;
		}
		#pragma unroll_loop_end
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
		#pragma unroll_loop_start
		for ( int i = 0; i < NUM_POINT_LIGHT_SHADOWS; i ++ ) {
			shadowWorldPosition = worldPosition + vec4( shadowWorldNormal * pointLightShadows[ i ].shadowNormalBias, 0 );
			vPointShadowCoord[ i ] = pointShadowMatrix[ i ] * shadowWorldPosition;
		}
		#pragma unroll_loop_end
	#endif
#endif
#if NUM_SPOT_LIGHT_COORDS > 0
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHT_COORDS; i ++ ) {
		shadowWorldPosition = worldPosition;
		#if ( defined( USE_SHADOWMAP ) && UNROLLED_LOOP_INDEX < NUM_SPOT_LIGHT_SHADOWS )
			shadowWorldPosition.xyz += shadowWorldNormal * spotLightShadows[ i ].shadowNormalBias;
		#endif
		vSpotLightCoord[ i ] = spotLightMatrix[ i ] * shadowWorldPosition;
	}
	#pragma unroll_loop_end
#endif`,Lu=`float getShadowMask() {
	float shadow = 1.0;
	#ifdef USE_SHADOWMAP
	#if NUM_DIR_LIGHT_SHADOWS > 0
	DirectionalLightShadow directionalLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_DIR_LIGHT_SHADOWS; i ++ ) {
		directionalLight = directionalLightShadows[ i ];
		shadow *= receiveShadow ? getShadow( directionalShadowMap[ i ], directionalLight.shadowMapSize, directionalLight.shadowBias, directionalLight.shadowRadius, vDirectionalShadowCoord[ i ] ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#if NUM_SPOT_LIGHT_SHADOWS > 0
	SpotLightShadow spotLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_SPOT_LIGHT_SHADOWS; i ++ ) {
		spotLight = spotLightShadows[ i ];
		shadow *= receiveShadow ? getShadow( spotShadowMap[ i ], spotLight.shadowMapSize, spotLight.shadowBias, spotLight.shadowRadius, vSpotLightCoord[ i ] ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#if NUM_POINT_LIGHT_SHADOWS > 0
	PointLightShadow pointLight;
	#pragma unroll_loop_start
	for ( int i = 0; i < NUM_POINT_LIGHT_SHADOWS; i ++ ) {
		pointLight = pointLightShadows[ i ];
		shadow *= receiveShadow ? getPointShadow( pointShadowMap[ i ], pointLight.shadowMapSize, pointLight.shadowBias, pointLight.shadowRadius, vPointShadowCoord[ i ], pointLight.shadowCameraNear, pointLight.shadowCameraFar ) : 1.0;
	}
	#pragma unroll_loop_end
	#endif
	#endif
	return shadow;
}`,Du=`#ifdef USE_SKINNING
	mat4 boneMatX = getBoneMatrix( skinIndex.x );
	mat4 boneMatY = getBoneMatrix( skinIndex.y );
	mat4 boneMatZ = getBoneMatrix( skinIndex.z );
	mat4 boneMatW = getBoneMatrix( skinIndex.w );
#endif`,Uu=`#ifdef USE_SKINNING
	uniform mat4 bindMatrix;
	uniform mat4 bindMatrixInverse;
	uniform highp sampler2D boneTexture;
	mat4 getBoneMatrix( const in float i ) {
		int size = textureSize( boneTexture, 0 ).x;
		int j = int( i ) * 4;
		int x = j % size;
		int y = j / size;
		vec4 v1 = texelFetch( boneTexture, ivec2( x, y ), 0 );
		vec4 v2 = texelFetch( boneTexture, ivec2( x + 1, y ), 0 );
		vec4 v3 = texelFetch( boneTexture, ivec2( x + 2, y ), 0 );
		vec4 v4 = texelFetch( boneTexture, ivec2( x + 3, y ), 0 );
		return mat4( v1, v2, v3, v4 );
	}
#endif`,Iu=`#ifdef USE_SKINNING
	vec4 skinVertex = bindMatrix * vec4( transformed, 1.0 );
	vec4 skinned = vec4( 0.0 );
	skinned += boneMatX * skinVertex * skinWeight.x;
	skinned += boneMatY * skinVertex * skinWeight.y;
	skinned += boneMatZ * skinVertex * skinWeight.z;
	skinned += boneMatW * skinVertex * skinWeight.w;
	transformed = ( bindMatrixInverse * skinned ).xyz;
#endif`,Nu=`#ifdef USE_SKINNING
	mat4 skinMatrix = mat4( 0.0 );
	skinMatrix += skinWeight.x * boneMatX;
	skinMatrix += skinWeight.y * boneMatY;
	skinMatrix += skinWeight.z * boneMatZ;
	skinMatrix += skinWeight.w * boneMatW;
	skinMatrix = bindMatrixInverse * skinMatrix * bindMatrix;
	objectNormal = vec4( skinMatrix * vec4( objectNormal, 0.0 ) ).xyz;
	#ifdef USE_TANGENT
		objectTangent = vec4( skinMatrix * vec4( objectTangent, 0.0 ) ).xyz;
	#endif
#endif`,Fu=`float specularStrength;
#ifdef USE_SPECULARMAP
	vec4 texelSpecular = texture2D( specularMap, vSpecularMapUv );
	specularStrength = texelSpecular.r;
#else
	specularStrength = 1.0;
#endif`,Ou=`#ifdef USE_SPECULARMAP
	uniform sampler2D specularMap;
#endif`,zu=`#if defined( TONE_MAPPING )
	gl_FragColor.rgb = toneMapping( gl_FragColor.rgb );
#endif`,Bu=`#ifndef saturate
#define saturate( a ) clamp( a, 0.0, 1.0 )
#endif
uniform float toneMappingExposure;
vec3 LinearToneMapping( vec3 color ) {
	return saturate( toneMappingExposure * color );
}
vec3 ReinhardToneMapping( vec3 color ) {
	color *= toneMappingExposure;
	return saturate( color / ( vec3( 1.0 ) + color ) );
}
vec3 OptimizedCineonToneMapping( vec3 color ) {
	color *= toneMappingExposure;
	color = max( vec3( 0.0 ), color - 0.004 );
	return pow( ( color * ( 6.2 * color + 0.5 ) ) / ( color * ( 6.2 * color + 1.7 ) + 0.06 ), vec3( 2.2 ) );
}
vec3 RRTAndODTFit( vec3 v ) {
	vec3 a = v * ( v + 0.0245786 ) - 0.000090537;
	vec3 b = v * ( 0.983729 * v + 0.4329510 ) + 0.238081;
	return a / b;
}
vec3 ACESFilmicToneMapping( vec3 color ) {
	const mat3 ACESInputMat = mat3(
		vec3( 0.59719, 0.07600, 0.02840 ),		vec3( 0.35458, 0.90834, 0.13383 ),
		vec3( 0.04823, 0.01566, 0.83777 )
	);
	const mat3 ACESOutputMat = mat3(
		vec3(  1.60475, -0.10208, -0.00327 ),		vec3( -0.53108,  1.10813, -0.07276 ),
		vec3( -0.07367, -0.00605,  1.07602 )
	);
	color *= toneMappingExposure / 0.6;
	color = ACESInputMat * color;
	color = RRTAndODTFit( color );
	color = ACESOutputMat * color;
	return saturate( color );
}
const mat3 LINEAR_REC2020_TO_LINEAR_SRGB = mat3(
	vec3( 1.6605, - 0.1246, - 0.0182 ),
	vec3( - 0.5876, 1.1329, - 0.1006 ),
	vec3( - 0.0728, - 0.0083, 1.1187 )
);
const mat3 LINEAR_SRGB_TO_LINEAR_REC2020 = mat3(
	vec3( 0.6274, 0.0691, 0.0164 ),
	vec3( 0.3293, 0.9195, 0.0880 ),
	vec3( 0.0433, 0.0113, 0.8956 )
);
vec3 agxDefaultContrastApprox( vec3 x ) {
	vec3 x2 = x * x;
	vec3 x4 = x2 * x2;
	return + 15.5 * x4 * x2
		- 40.14 * x4 * x
		+ 31.96 * x4
		- 6.868 * x2 * x
		+ 0.4298 * x2
		+ 0.1191 * x
		- 0.00232;
}
vec3 AgXToneMapping( vec3 color ) {
	const mat3 AgXInsetMatrix = mat3(
		vec3( 0.856627153315983, 0.137318972929847, 0.11189821299995 ),
		vec3( 0.0951212405381588, 0.761241990602591, 0.0767994186031903 ),
		vec3( 0.0482516061458583, 0.101439036467562, 0.811302368396859 )
	);
	const mat3 AgXOutsetMatrix = mat3(
		vec3( 1.1271005818144368, - 0.1413297634984383, - 0.14132976349843826 ),
		vec3( - 0.11060664309660323, 1.157823702216272, - 0.11060664309660294 ),
		vec3( - 0.016493938717834573, - 0.016493938717834257, 1.2519364065950405 )
	);
	const float AgxMinEv = - 12.47393;	const float AgxMaxEv = 4.026069;
	color = LINEAR_SRGB_TO_LINEAR_REC2020 * color;
	color *= toneMappingExposure;
	color = AgXInsetMatrix * color;
	color = max( color, 1e-10 );	color = log2( color );
	color = ( color - AgxMinEv ) / ( AgxMaxEv - AgxMinEv );
	color = clamp( color, 0.0, 1.0 );
	color = agxDefaultContrastApprox( color );
	color = AgXOutsetMatrix * color;
	color = pow( max( vec3( 0.0 ), color ), vec3( 2.2 ) );
	color = LINEAR_REC2020_TO_LINEAR_SRGB * color;
	return color;
}
vec3 CustomToneMapping( vec3 color ) { return color; }`,Vu=`#ifdef USE_TRANSMISSION
	material.transmission = transmission;
	material.transmissionAlpha = 1.0;
	material.thickness = thickness;
	material.attenuationDistance = attenuationDistance;
	material.attenuationColor = attenuationColor;
	#ifdef USE_TRANSMISSIONMAP
		material.transmission *= texture2D( transmissionMap, vTransmissionMapUv ).r;
	#endif
	#ifdef USE_THICKNESSMAP
		material.thickness *= texture2D( thicknessMap, vThicknessMapUv ).g;
	#endif
	vec3 pos = vWorldPosition;
	vec3 v = normalize( cameraPosition - pos );
	vec3 n = inverseTransformDirection( normal, viewMatrix );
	vec4 transmitted = getIBLVolumeRefraction(
		n, v, material.roughness, material.diffuseColor, material.specularColor, material.specularF90,
		pos, modelMatrix, viewMatrix, projectionMatrix, material.ior, material.thickness,
		material.attenuationColor, material.attenuationDistance );
	material.transmissionAlpha = mix( material.transmissionAlpha, transmitted.a, material.transmission );
	totalDiffuse = mix( totalDiffuse, transmitted.rgb, material.transmission );
#endif`,Hu=`#ifdef USE_TRANSMISSION
	uniform float transmission;
	uniform float thickness;
	uniform float attenuationDistance;
	uniform vec3 attenuationColor;
	#ifdef USE_TRANSMISSIONMAP
		uniform sampler2D transmissionMap;
	#endif
	#ifdef USE_THICKNESSMAP
		uniform sampler2D thicknessMap;
	#endif
	uniform vec2 transmissionSamplerSize;
	uniform sampler2D transmissionSamplerMap;
	uniform mat4 modelMatrix;
	uniform mat4 projectionMatrix;
	varying vec3 vWorldPosition;
	float w0( float a ) {
		return ( 1.0 / 6.0 ) * ( a * ( a * ( - a + 3.0 ) - 3.0 ) + 1.0 );
	}
	float w1( float a ) {
		return ( 1.0 / 6.0 ) * ( a *  a * ( 3.0 * a - 6.0 ) + 4.0 );
	}
	float w2( float a ){
		return ( 1.0 / 6.0 ) * ( a * ( a * ( - 3.0 * a + 3.0 ) + 3.0 ) + 1.0 );
	}
	float w3( float a ) {
		return ( 1.0 / 6.0 ) * ( a * a * a );
	}
	float g0( float a ) {
		return w0( a ) + w1( a );
	}
	float g1( float a ) {
		return w2( a ) + w3( a );
	}
	float h0( float a ) {
		return - 1.0 + w1( a ) / ( w0( a ) + w1( a ) );
	}
	float h1( float a ) {
		return 1.0 + w3( a ) / ( w2( a ) + w3( a ) );
	}
	vec4 bicubic( sampler2D tex, vec2 uv, vec4 texelSize, float lod ) {
		uv = uv * texelSize.zw + 0.5;
		vec2 iuv = floor( uv );
		vec2 fuv = fract( uv );
		float g0x = g0( fuv.x );
		float g1x = g1( fuv.x );
		float h0x = h0( fuv.x );
		float h1x = h1( fuv.x );
		float h0y = h0( fuv.y );
		float h1y = h1( fuv.y );
		vec2 p0 = ( vec2( iuv.x + h0x, iuv.y + h0y ) - 0.5 ) * texelSize.xy;
		vec2 p1 = ( vec2( iuv.x + h1x, iuv.y + h0y ) - 0.5 ) * texelSize.xy;
		vec2 p2 = ( vec2( iuv.x + h0x, iuv.y + h1y ) - 0.5 ) * texelSize.xy;
		vec2 p3 = ( vec2( iuv.x + h1x, iuv.y + h1y ) - 0.5 ) * texelSize.xy;
		return g0( fuv.y ) * ( g0x * textureLod( tex, p0, lod ) + g1x * textureLod( tex, p1, lod ) ) +
			g1( fuv.y ) * ( g0x * textureLod( tex, p2, lod ) + g1x * textureLod( tex, p3, lod ) );
	}
	vec4 textureBicubic( sampler2D sampler, vec2 uv, float lod ) {
		vec2 fLodSize = vec2( textureSize( sampler, int( lod ) ) );
		vec2 cLodSize = vec2( textureSize( sampler, int( lod + 1.0 ) ) );
		vec2 fLodSizeInv = 1.0 / fLodSize;
		vec2 cLodSizeInv = 1.0 / cLodSize;
		vec4 fSample = bicubic( sampler, uv, vec4( fLodSizeInv, fLodSize ), floor( lod ) );
		vec4 cSample = bicubic( sampler, uv, vec4( cLodSizeInv, cLodSize ), ceil( lod ) );
		return mix( fSample, cSample, fract( lod ) );
	}
	vec3 getVolumeTransmissionRay( const in vec3 n, const in vec3 v, const in float thickness, const in float ior, const in mat4 modelMatrix ) {
		vec3 refractionVector = refract( - v, normalize( n ), 1.0 / ior );
		vec3 modelScale;
		modelScale.x = length( vec3( modelMatrix[ 0 ].xyz ) );
		modelScale.y = length( vec3( modelMatrix[ 1 ].xyz ) );
		modelScale.z = length( vec3( modelMatrix[ 2 ].xyz ) );
		return normalize( refractionVector ) * thickness * modelScale;
	}
	float applyIorToRoughness( const in float roughness, const in float ior ) {
		return roughness * clamp( ior * 2.0 - 2.0, 0.0, 1.0 );
	}
	vec4 getTransmissionSample( const in vec2 fragCoord, const in float roughness, const in float ior ) {
		float lod = log2( transmissionSamplerSize.x ) * applyIorToRoughness( roughness, ior );
		return textureBicubic( transmissionSamplerMap, fragCoord.xy, lod );
	}
	vec3 volumeAttenuation( const in float transmissionDistance, const in vec3 attenuationColor, const in float attenuationDistance ) {
		if ( isinf( attenuationDistance ) ) {
			return vec3( 1.0 );
		} else {
			vec3 attenuationCoefficient = -log( attenuationColor ) / attenuationDistance;
			vec3 transmittance = exp( - attenuationCoefficient * transmissionDistance );			return transmittance;
		}
	}
	vec4 getIBLVolumeRefraction( const in vec3 n, const in vec3 v, const in float roughness, const in vec3 diffuseColor,
		const in vec3 specularColor, const in float specularF90, const in vec3 position, const in mat4 modelMatrix,
		const in mat4 viewMatrix, const in mat4 projMatrix, const in float ior, const in float thickness,
		const in vec3 attenuationColor, const in float attenuationDistance ) {
		vec3 transmissionRay = getVolumeTransmissionRay( n, v, thickness, ior, modelMatrix );
		vec3 refractedRayExit = position + transmissionRay;
		vec4 ndcPos = projMatrix * viewMatrix * vec4( refractedRayExit, 1.0 );
		vec2 refractionCoords = ndcPos.xy / ndcPos.w;
		refractionCoords += 1.0;
		refractionCoords /= 2.0;
		vec4 transmittedLight = getTransmissionSample( refractionCoords, roughness, ior );
		vec3 transmittance = diffuseColor * volumeAttenuation( length( transmissionRay ), attenuationColor, attenuationDistance );
		vec3 attenuatedColor = transmittance * transmittedLight.rgb;
		vec3 F = EnvironmentBRDF( n, v, specularColor, specularF90, roughness );
		float transmittanceFactor = ( transmittance.r + transmittance.g + transmittance.b ) / 3.0;
		return vec4( ( 1.0 - F ) * attenuatedColor, 1.0 - ( 1.0 - transmittedLight.a ) * transmittanceFactor );
	}
#endif`,Gu=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	varying vec2 vUv;
#endif
#ifdef USE_MAP
	varying vec2 vMapUv;
#endif
#ifdef USE_ALPHAMAP
	varying vec2 vAlphaMapUv;
#endif
#ifdef USE_LIGHTMAP
	varying vec2 vLightMapUv;
#endif
#ifdef USE_AOMAP
	varying vec2 vAoMapUv;
#endif
#ifdef USE_BUMPMAP
	varying vec2 vBumpMapUv;
#endif
#ifdef USE_NORMALMAP
	varying vec2 vNormalMapUv;
#endif
#ifdef USE_EMISSIVEMAP
	varying vec2 vEmissiveMapUv;
#endif
#ifdef USE_METALNESSMAP
	varying vec2 vMetalnessMapUv;
#endif
#ifdef USE_ROUGHNESSMAP
	varying vec2 vRoughnessMapUv;
#endif
#ifdef USE_ANISOTROPYMAP
	varying vec2 vAnisotropyMapUv;
#endif
#ifdef USE_CLEARCOATMAP
	varying vec2 vClearcoatMapUv;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	varying vec2 vClearcoatNormalMapUv;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	varying vec2 vClearcoatRoughnessMapUv;
#endif
#ifdef USE_IRIDESCENCEMAP
	varying vec2 vIridescenceMapUv;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	varying vec2 vIridescenceThicknessMapUv;
#endif
#ifdef USE_SHEEN_COLORMAP
	varying vec2 vSheenColorMapUv;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	varying vec2 vSheenRoughnessMapUv;
#endif
#ifdef USE_SPECULARMAP
	varying vec2 vSpecularMapUv;
#endif
#ifdef USE_SPECULAR_COLORMAP
	varying vec2 vSpecularColorMapUv;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	varying vec2 vSpecularIntensityMapUv;
#endif
#ifdef USE_TRANSMISSIONMAP
	uniform mat3 transmissionMapTransform;
	varying vec2 vTransmissionMapUv;
#endif
#ifdef USE_THICKNESSMAP
	uniform mat3 thicknessMapTransform;
	varying vec2 vThicknessMapUv;
#endif`,ku=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	varying vec2 vUv;
#endif
#ifdef USE_MAP
	uniform mat3 mapTransform;
	varying vec2 vMapUv;
#endif
#ifdef USE_ALPHAMAP
	uniform mat3 alphaMapTransform;
	varying vec2 vAlphaMapUv;
#endif
#ifdef USE_LIGHTMAP
	uniform mat3 lightMapTransform;
	varying vec2 vLightMapUv;
#endif
#ifdef USE_AOMAP
	uniform mat3 aoMapTransform;
	varying vec2 vAoMapUv;
#endif
#ifdef USE_BUMPMAP
	uniform mat3 bumpMapTransform;
	varying vec2 vBumpMapUv;
#endif
#ifdef USE_NORMALMAP
	uniform mat3 normalMapTransform;
	varying vec2 vNormalMapUv;
#endif
#ifdef USE_DISPLACEMENTMAP
	uniform mat3 displacementMapTransform;
	varying vec2 vDisplacementMapUv;
#endif
#ifdef USE_EMISSIVEMAP
	uniform mat3 emissiveMapTransform;
	varying vec2 vEmissiveMapUv;
#endif
#ifdef USE_METALNESSMAP
	uniform mat3 metalnessMapTransform;
	varying vec2 vMetalnessMapUv;
#endif
#ifdef USE_ROUGHNESSMAP
	uniform mat3 roughnessMapTransform;
	varying vec2 vRoughnessMapUv;
#endif
#ifdef USE_ANISOTROPYMAP
	uniform mat3 anisotropyMapTransform;
	varying vec2 vAnisotropyMapUv;
#endif
#ifdef USE_CLEARCOATMAP
	uniform mat3 clearcoatMapTransform;
	varying vec2 vClearcoatMapUv;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	uniform mat3 clearcoatNormalMapTransform;
	varying vec2 vClearcoatNormalMapUv;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	uniform mat3 clearcoatRoughnessMapTransform;
	varying vec2 vClearcoatRoughnessMapUv;
#endif
#ifdef USE_SHEEN_COLORMAP
	uniform mat3 sheenColorMapTransform;
	varying vec2 vSheenColorMapUv;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	uniform mat3 sheenRoughnessMapTransform;
	varying vec2 vSheenRoughnessMapUv;
#endif
#ifdef USE_IRIDESCENCEMAP
	uniform mat3 iridescenceMapTransform;
	varying vec2 vIridescenceMapUv;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	uniform mat3 iridescenceThicknessMapTransform;
	varying vec2 vIridescenceThicknessMapUv;
#endif
#ifdef USE_SPECULARMAP
	uniform mat3 specularMapTransform;
	varying vec2 vSpecularMapUv;
#endif
#ifdef USE_SPECULAR_COLORMAP
	uniform mat3 specularColorMapTransform;
	varying vec2 vSpecularColorMapUv;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	uniform mat3 specularIntensityMapTransform;
	varying vec2 vSpecularIntensityMapUv;
#endif
#ifdef USE_TRANSMISSIONMAP
	uniform mat3 transmissionMapTransform;
	varying vec2 vTransmissionMapUv;
#endif
#ifdef USE_THICKNESSMAP
	uniform mat3 thicknessMapTransform;
	varying vec2 vThicknessMapUv;
#endif`,Wu=`#if defined( USE_UV ) || defined( USE_ANISOTROPY )
	vUv = vec3( uv, 1 ).xy;
#endif
#ifdef USE_MAP
	vMapUv = ( mapTransform * vec3( MAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ALPHAMAP
	vAlphaMapUv = ( alphaMapTransform * vec3( ALPHAMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_LIGHTMAP
	vLightMapUv = ( lightMapTransform * vec3( LIGHTMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_AOMAP
	vAoMapUv = ( aoMapTransform * vec3( AOMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_BUMPMAP
	vBumpMapUv = ( bumpMapTransform * vec3( BUMPMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_NORMALMAP
	vNormalMapUv = ( normalMapTransform * vec3( NORMALMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_DISPLACEMENTMAP
	vDisplacementMapUv = ( displacementMapTransform * vec3( DISPLACEMENTMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_EMISSIVEMAP
	vEmissiveMapUv = ( emissiveMapTransform * vec3( EMISSIVEMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_METALNESSMAP
	vMetalnessMapUv = ( metalnessMapTransform * vec3( METALNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ROUGHNESSMAP
	vRoughnessMapUv = ( roughnessMapTransform * vec3( ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_ANISOTROPYMAP
	vAnisotropyMapUv = ( anisotropyMapTransform * vec3( ANISOTROPYMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOATMAP
	vClearcoatMapUv = ( clearcoatMapTransform * vec3( CLEARCOATMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOAT_NORMALMAP
	vClearcoatNormalMapUv = ( clearcoatNormalMapTransform * vec3( CLEARCOAT_NORMALMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_CLEARCOAT_ROUGHNESSMAP
	vClearcoatRoughnessMapUv = ( clearcoatRoughnessMapTransform * vec3( CLEARCOAT_ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_IRIDESCENCEMAP
	vIridescenceMapUv = ( iridescenceMapTransform * vec3( IRIDESCENCEMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_IRIDESCENCE_THICKNESSMAP
	vIridescenceThicknessMapUv = ( iridescenceThicknessMapTransform * vec3( IRIDESCENCE_THICKNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SHEEN_COLORMAP
	vSheenColorMapUv = ( sheenColorMapTransform * vec3( SHEEN_COLORMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SHEEN_ROUGHNESSMAP
	vSheenRoughnessMapUv = ( sheenRoughnessMapTransform * vec3( SHEEN_ROUGHNESSMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULARMAP
	vSpecularMapUv = ( specularMapTransform * vec3( SPECULARMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULAR_COLORMAP
	vSpecularColorMapUv = ( specularColorMapTransform * vec3( SPECULAR_COLORMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_SPECULAR_INTENSITYMAP
	vSpecularIntensityMapUv = ( specularIntensityMapTransform * vec3( SPECULAR_INTENSITYMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_TRANSMISSIONMAP
	vTransmissionMapUv = ( transmissionMapTransform * vec3( TRANSMISSIONMAP_UV, 1 ) ).xy;
#endif
#ifdef USE_THICKNESSMAP
	vThicknessMapUv = ( thicknessMapTransform * vec3( THICKNESSMAP_UV, 1 ) ).xy;
#endif`,Xu=`#if defined( USE_ENVMAP ) || defined( DISTANCE ) || defined ( USE_SHADOWMAP ) || defined ( USE_TRANSMISSION ) || NUM_SPOT_LIGHT_COORDS > 0
	vec4 worldPosition = vec4( transformed, 1.0 );
	#ifdef USE_BATCHING
		worldPosition = batchingMatrix * worldPosition;
	#endif
	#ifdef USE_INSTANCING
		worldPosition = instanceMatrix * worldPosition;
	#endif
	worldPosition = modelMatrix * worldPosition;
#endif`;const qu=`varying vec2 vUv;
uniform mat3 uvTransform;
void main() {
	vUv = ( uvTransform * vec3( uv, 1 ) ).xy;
	gl_Position = vec4( position.xy, 1.0, 1.0 );
}`,Yu=`uniform sampler2D t2D;
uniform float backgroundIntensity;
varying vec2 vUv;
void main() {
	vec4 texColor = texture2D( t2D, vUv );
	#ifdef DECODE_VIDEO_TEXTURE
		texColor = vec4( mix( pow( texColor.rgb * 0.9478672986 + vec3( 0.0521327014 ), vec3( 2.4 ) ), texColor.rgb * 0.0773993808, vec3( lessThanEqual( texColor.rgb, vec3( 0.04045 ) ) ) ), texColor.w );
	#endif
	texColor.rgb *= backgroundIntensity;
	gl_FragColor = texColor;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,$u=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
	gl_Position.z = gl_Position.w;
}`,ju=`#ifdef ENVMAP_TYPE_CUBE
	uniform samplerCube envMap;
#elif defined( ENVMAP_TYPE_CUBE_UV )
	uniform sampler2D envMap;
#endif
uniform float flipEnvMap;
uniform float backgroundBlurriness;
uniform float backgroundIntensity;
varying vec3 vWorldDirection;
#include <cube_uv_reflection_fragment>
void main() {
	#ifdef ENVMAP_TYPE_CUBE
		vec4 texColor = textureCube( envMap, vec3( flipEnvMap * vWorldDirection.x, vWorldDirection.yz ) );
	#elif defined( ENVMAP_TYPE_CUBE_UV )
		vec4 texColor = textureCubeUV( envMap, vWorldDirection, backgroundBlurriness );
	#else
		vec4 texColor = vec4( 0.0, 0.0, 0.0, 1.0 );
	#endif
	texColor.rgb *= backgroundIntensity;
	gl_FragColor = texColor;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,Zu=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
	gl_Position.z = gl_Position.w;
}`,Ku=`uniform samplerCube tCube;
uniform float tFlip;
uniform float opacity;
varying vec3 vWorldDirection;
void main() {
	vec4 texColor = textureCube( tCube, vec3( tFlip * vWorldDirection.x, vWorldDirection.yz ) );
	gl_FragColor = texColor;
	gl_FragColor.a *= opacity;
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,Ju=`#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
varying vec2 vHighPrecisionZW;
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <skinbase_vertex>
	#ifdef USE_DISPLACEMENTMAP
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vHighPrecisionZW = gl_Position.zw;
}`,Qu=`#if DEPTH_PACKING == 3200
	uniform float opacity;
#endif
#include <common>
#include <packing>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
varying vec2 vHighPrecisionZW;
void main() {
	#include <clipping_planes_fragment>
	vec4 diffuseColor = vec4( 1.0 );
	#if DEPTH_PACKING == 3200
		diffuseColor.a = opacity;
	#endif
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <logdepthbuf_fragment>
	float fragCoordZ = 0.5 * vHighPrecisionZW[0] / vHighPrecisionZW[1] + 0.5;
	#if DEPTH_PACKING == 3200
		gl_FragColor = vec4( vec3( 1.0 - fragCoordZ ), opacity );
	#elif DEPTH_PACKING == 3201
		gl_FragColor = packDepthToRGBA( fragCoordZ );
	#endif
}`,th=`#define DISTANCE
varying vec3 vWorldPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <skinbase_vertex>
	#ifdef USE_DISPLACEMENTMAP
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <worldpos_vertex>
	#include <clipping_planes_vertex>
	vWorldPosition = worldPosition.xyz;
}`,eh=`#define DISTANCE
uniform vec3 referencePosition;
uniform float nearDistance;
uniform float farDistance;
varying vec3 vWorldPosition;
#include <common>
#include <packing>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <clipping_planes_pars_fragment>
void main () {
	#include <clipping_planes_fragment>
	vec4 diffuseColor = vec4( 1.0 );
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	float dist = length( vWorldPosition - referencePosition );
	dist = ( dist - nearDistance ) / ( farDistance - nearDistance );
	dist = saturate( dist );
	gl_FragColor = packDepthToRGBA( dist );
}`,nh=`varying vec3 vWorldDirection;
#include <common>
void main() {
	vWorldDirection = transformDirection( position, modelMatrix );
	#include <begin_vertex>
	#include <project_vertex>
}`,ih=`uniform sampler2D tEquirect;
varying vec3 vWorldDirection;
#include <common>
void main() {
	vec3 direction = normalize( vWorldDirection );
	vec2 sampleUV = equirectUv( direction );
	gl_FragColor = texture2D( tEquirect, sampleUV );
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
}`,rh=`uniform float scale;
attribute float lineDistance;
varying float vLineDistance;
#include <common>
#include <uv_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	vLineDistance = scale * lineDistance;
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
}`,ah=`uniform vec3 diffuse;
uniform float opacity;
uniform float dashSize;
uniform float totalSize;
varying float vLineDistance;
#include <common>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	if ( mod( vLineDistance, totalSize ) > dashSize ) {
		discard;
	}
	vec3 outgoingLight = vec3( 0.0 );
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
}`,sh=`#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#if defined ( USE_ENVMAP ) || defined ( USE_SKINNING )
		#include <beginnormal_vertex>
		#include <morphnormal_vertex>
		#include <skinbase_vertex>
		#include <skinnormal_vertex>
		#include <defaultnormal_vertex>
	#endif
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <fog_vertex>
}`,oh=`uniform vec3 diffuse;
uniform float opacity;
#ifndef FLAT_SHADED
	varying vec3 vNormal;
#endif
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	#ifdef USE_LIGHTMAP
		vec4 lightMapTexel = texture2D( lightMap, vLightMapUv );
		reflectedLight.indirectDiffuse += lightMapTexel.rgb * lightMapIntensity * RECIPROCAL_PI;
	#else
		reflectedLight.indirectDiffuse += vec3( 1.0 );
	#endif
	#include <aomap_fragment>
	reflectedLight.indirectDiffuse *= diffuseColor.rgb;
	vec3 outgoingLight = reflectedLight.indirectDiffuse;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,lh=`#define LAMBERT
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,ch=`#define LAMBERT
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float opacity;
#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_lambert_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	vec4 diffuseColor = vec4( diffuse, opacity );
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_lambert_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + totalEmissiveRadiance;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,uh=`#define MATCAP
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <color_pars_vertex>
#include <displacementmap_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
	vViewPosition = - mvPosition.xyz;
}`,hh=`#define MATCAP
uniform vec3 diffuse;
uniform float opacity;
uniform sampler2D matcap;
varying vec3 vViewPosition;
#include <common>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <normal_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	vec3 viewDir = normalize( vViewPosition );
	vec3 x = normalize( vec3( viewDir.z, 0.0, - viewDir.x ) );
	vec3 y = cross( viewDir, x );
	vec2 uv = vec2( dot( x, normal ), dot( y, normal ) ) * 0.495 + 0.5;
	#ifdef USE_MATCAP
		vec4 matcapColor = texture2D( matcap, uv );
	#else
		vec4 matcapColor = vec4( vec3( mix( 0.2, 0.8, uv.y ) ), 1.0 );
	#endif
	vec3 outgoingLight = diffuseColor.rgb * matcapColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,dh=`#define NORMAL
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	varying vec3 vViewPosition;
#endif
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	vViewPosition = - mvPosition.xyz;
#endif
}`,fh=`#define NORMAL
uniform float opacity;
#if defined( FLAT_SHADED ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP_TANGENTSPACE )
	varying vec3 vViewPosition;
#endif
#include <packing>
#include <uv_pars_fragment>
#include <normal_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	#include <logdepthbuf_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	gl_FragColor = vec4( packNormalToRGB( normal ), opacity );
	#ifdef OPAQUE
		gl_FragColor.a = 1.0;
	#endif
}`,ph=`#define PHONG
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <envmap_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,mh=`#define PHONG
uniform vec3 diffuse;
uniform vec3 emissive;
uniform vec3 specular;
uniform float shininess;
uniform float opacity;
#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_phong_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <specularmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	vec4 diffuseColor = vec4( diffuse, opacity );
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <specularmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_phong_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + reflectedLight.directSpecular + reflectedLight.indirectSpecular + totalEmissiveRadiance;
	#include <envmap_fragment>
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,gh=`#define STANDARD
varying vec3 vViewPosition;
#ifdef USE_TRANSMISSION
	varying vec3 vWorldPosition;
#endif
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
#ifdef USE_TRANSMISSION
	vWorldPosition = worldPosition.xyz;
#endif
}`,_h=`#define STANDARD
#ifdef PHYSICAL
	#define IOR
	#define USE_SPECULAR
#endif
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float roughness;
uniform float metalness;
uniform float opacity;
#ifdef IOR
	uniform float ior;
#endif
#ifdef USE_SPECULAR
	uniform float specularIntensity;
	uniform vec3 specularColor;
	#ifdef USE_SPECULAR_COLORMAP
		uniform sampler2D specularColorMap;
	#endif
	#ifdef USE_SPECULAR_INTENSITYMAP
		uniform sampler2D specularIntensityMap;
	#endif
#endif
#ifdef USE_CLEARCOAT
	uniform float clearcoat;
	uniform float clearcoatRoughness;
#endif
#ifdef USE_IRIDESCENCE
	uniform float iridescence;
	uniform float iridescenceIOR;
	uniform float iridescenceThicknessMinimum;
	uniform float iridescenceThicknessMaximum;
#endif
#ifdef USE_SHEEN
	uniform vec3 sheenColor;
	uniform float sheenRoughness;
	#ifdef USE_SHEEN_COLORMAP
		uniform sampler2D sheenColorMap;
	#endif
	#ifdef USE_SHEEN_ROUGHNESSMAP
		uniform sampler2D sheenRoughnessMap;
	#endif
#endif
#ifdef USE_ANISOTROPY
	uniform vec2 anisotropyVector;
	#ifdef USE_ANISOTROPYMAP
		uniform sampler2D anisotropyMap;
	#endif
#endif
varying vec3 vViewPosition;
#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <iridescence_fragment>
#include <cube_uv_reflection_fragment>
#include <envmap_common_pars_fragment>
#include <envmap_physical_pars_fragment>
#include <fog_pars_fragment>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_physical_pars_fragment>
#include <transmission_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <clearcoat_pars_fragment>
#include <iridescence_pars_fragment>
#include <roughnessmap_pars_fragment>
#include <metalnessmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	vec4 diffuseColor = vec4( diffuse, opacity );
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <roughnessmap_fragment>
	#include <metalnessmap_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <clearcoat_normal_fragment_begin>
	#include <clearcoat_normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_physical_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 totalDiffuse = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse;
	vec3 totalSpecular = reflectedLight.directSpecular + reflectedLight.indirectSpecular;
	#include <transmission_fragment>
	vec3 outgoingLight = totalDiffuse + totalSpecular + totalEmissiveRadiance;
	#ifdef USE_SHEEN
		float sheenEnergyComp = 1.0 - 0.157 * max3( material.sheenColor );
		outgoingLight = outgoingLight * sheenEnergyComp + sheenSpecularDirect + sheenSpecularIndirect;
	#endif
	#ifdef USE_CLEARCOAT
		float dotNVcc = saturate( dot( geometryClearcoatNormal, geometryViewDir ) );
		vec3 Fcc = F_Schlick( material.clearcoatF0, material.clearcoatF90, dotNVcc );
		outgoingLight = outgoingLight * ( 1.0 - material.clearcoat * Fcc ) + ( clearcoatSpecularDirect + clearcoatSpecularIndirect ) * material.clearcoat;
	#endif
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,vh=`#define TOON
varying vec3 vViewPosition;
#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <normal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <displacementmap_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	vViewPosition = - mvPosition.xyz;
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,xh=`#define TOON
uniform vec3 diffuse;
uniform vec3 emissive;
uniform float opacity;
#include <common>
#include <packing>
#include <dithering_pars_fragment>
#include <color_pars_fragment>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <aomap_pars_fragment>
#include <lightmap_pars_fragment>
#include <emissivemap_pars_fragment>
#include <gradientmap_pars_fragment>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <normal_pars_fragment>
#include <lights_toon_pars_fragment>
#include <shadowmap_pars_fragment>
#include <bumpmap_pars_fragment>
#include <normalmap_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	vec4 diffuseColor = vec4( diffuse, opacity );
	ReflectedLight reflectedLight = ReflectedLight( vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ), vec3( 0.0 ) );
	vec3 totalEmissiveRadiance = emissive;
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <color_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	#include <normal_fragment_begin>
	#include <normal_fragment_maps>
	#include <emissivemap_fragment>
	#include <lights_toon_fragment>
	#include <lights_fragment_begin>
	#include <lights_fragment_maps>
	#include <lights_fragment_end>
	#include <aomap_fragment>
	vec3 outgoingLight = reflectedLight.directDiffuse + reflectedLight.indirectDiffuse + totalEmissiveRadiance;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
	#include <dithering_fragment>
}`,Sh=`uniform float size;
uniform float scale;
#include <common>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
#ifdef USE_POINTS_UV
	varying vec2 vUv;
	uniform mat3 uvTransform;
#endif
void main() {
	#ifdef USE_POINTS_UV
		vUv = ( uvTransform * vec3( uv, 1 ) ).xy;
	#endif
	#include <color_vertex>
	#include <morphcolor_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <project_vertex>
	gl_PointSize = size;
	#ifdef USE_SIZEATTENUATION
		bool isPerspective = isPerspectiveMatrix( projectionMatrix );
		if ( isPerspective ) gl_PointSize *= ( scale / - mvPosition.z );
	#endif
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <worldpos_vertex>
	#include <fog_vertex>
}`,yh=`uniform vec3 diffuse;
uniform float opacity;
#include <common>
#include <color_pars_fragment>
#include <map_particle_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	vec3 outgoingLight = vec3( 0.0 );
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <logdepthbuf_fragment>
	#include <map_particle_fragment>
	#include <color_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
	#include <premultiplied_alpha_fragment>
}`,Th=`#include <common>
#include <batching_pars_vertex>
#include <fog_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <shadowmap_pars_vertex>
void main() {
	#include <batching_vertex>
	#include <beginnormal_vertex>
	#include <morphnormal_vertex>
	#include <skinbase_vertex>
	#include <skinnormal_vertex>
	#include <defaultnormal_vertex>
	#include <begin_vertex>
	#include <morphtarget_vertex>
	#include <skinning_vertex>
	#include <project_vertex>
	#include <logdepthbuf_vertex>
	#include <worldpos_vertex>
	#include <shadowmap_vertex>
	#include <fog_vertex>
}`,Mh=`uniform vec3 color;
uniform float opacity;
#include <common>
#include <packing>
#include <fog_pars_fragment>
#include <bsdfs>
#include <lights_pars_begin>
#include <logdepthbuf_pars_fragment>
#include <shadowmap_pars_fragment>
#include <shadowmask_pars_fragment>
void main() {
	#include <logdepthbuf_fragment>
	gl_FragColor = vec4( color, opacity * ( 1.0 - getShadowMask() ) );
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
}`,Eh=`uniform float rotation;
uniform vec2 center;
#include <common>
#include <uv_pars_vertex>
#include <fog_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>
void main() {
	#include <uv_vertex>
	vec4 mvPosition = modelViewMatrix * vec4( 0.0, 0.0, 0.0, 1.0 );
	vec2 scale;
	scale.x = length( vec3( modelMatrix[ 0 ].x, modelMatrix[ 0 ].y, modelMatrix[ 0 ].z ) );
	scale.y = length( vec3( modelMatrix[ 1 ].x, modelMatrix[ 1 ].y, modelMatrix[ 1 ].z ) );
	#ifndef USE_SIZEATTENUATION
		bool isPerspective = isPerspectiveMatrix( projectionMatrix );
		if ( isPerspective ) scale *= - mvPosition.z;
	#endif
	vec2 alignedPosition = ( position.xy - ( center - vec2( 0.5 ) ) ) * scale;
	vec2 rotatedPosition;
	rotatedPosition.x = cos( rotation ) * alignedPosition.x - sin( rotation ) * alignedPosition.y;
	rotatedPosition.y = sin( rotation ) * alignedPosition.x + cos( rotation ) * alignedPosition.y;
	mvPosition.xy += rotatedPosition;
	gl_Position = projectionMatrix * mvPosition;
	#include <logdepthbuf_vertex>
	#include <clipping_planes_vertex>
	#include <fog_vertex>
}`,bh=`uniform vec3 diffuse;
uniform float opacity;
#include <common>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <alphamap_pars_fragment>
#include <alphatest_pars_fragment>
#include <alphahash_pars_fragment>
#include <fog_pars_fragment>
#include <logdepthbuf_pars_fragment>
#include <clipping_planes_pars_fragment>
void main() {
	#include <clipping_planes_fragment>
	vec3 outgoingLight = vec3( 0.0 );
	vec4 diffuseColor = vec4( diffuse, opacity );
	#include <logdepthbuf_fragment>
	#include <map_fragment>
	#include <alphamap_fragment>
	#include <alphatest_fragment>
	#include <alphahash_fragment>
	outgoingLight = diffuseColor.rgb;
	#include <opaque_fragment>
	#include <tonemapping_fragment>
	#include <colorspace_fragment>
	#include <fog_fragment>
}`,Dt={alphahash_fragment:Yl,alphahash_pars_fragment:$l,alphamap_fragment:jl,alphamap_pars_fragment:Zl,alphatest_fragment:Kl,alphatest_pars_fragment:Jl,aomap_fragment:Ql,aomap_pars_fragment:tc,batching_pars_vertex:ec,batching_vertex:nc,begin_vertex:ic,beginnormal_vertex:rc,bsdfs:ac,iridescence_fragment:sc,bumpmap_pars_fragment:oc,clipping_planes_fragment:lc,clipping_planes_pars_fragment:cc,clipping_planes_pars_vertex:uc,clipping_planes_vertex:hc,color_fragment:dc,color_pars_fragment:fc,color_pars_vertex:pc,color_vertex:mc,common:gc,cube_uv_reflection_fragment:_c,defaultnormal_vertex:vc,displacementmap_pars_vertex:xc,displacementmap_vertex:Sc,emissivemap_fragment:yc,emissivemap_pars_fragment:Tc,colorspace_fragment:Mc,colorspace_pars_fragment:Ec,envmap_fragment:bc,envmap_common_pars_fragment:Ac,envmap_pars_fragment:wc,envmap_pars_vertex:Rc,envmap_physical_pars_fragment:Vc,envmap_vertex:Cc,fog_vertex:Pc,fog_pars_vertex:Lc,fog_fragment:Dc,fog_pars_fragment:Uc,gradientmap_pars_fragment:Ic,lightmap_fragment:Nc,lightmap_pars_fragment:Fc,lights_lambert_fragment:Oc,lights_lambert_pars_fragment:zc,lights_pars_begin:Bc,lights_toon_fragment:Hc,lights_toon_pars_fragment:Gc,lights_phong_fragment:kc,lights_phong_pars_fragment:Wc,lights_physical_fragment:Xc,lights_physical_pars_fragment:qc,lights_fragment_begin:Yc,lights_fragment_maps:$c,lights_fragment_end:jc,logdepthbuf_fragment:Zc,logdepthbuf_pars_fragment:Kc,logdepthbuf_pars_vertex:Jc,logdepthbuf_vertex:Qc,map_fragment:tu,map_pars_fragment:eu,map_particle_fragment:nu,map_particle_pars_fragment:iu,metalnessmap_fragment:ru,metalnessmap_pars_fragment:au,morphcolor_vertex:su,morphnormal_vertex:ou,morphtarget_pars_vertex:lu,morphtarget_vertex:cu,normal_fragment_begin:uu,normal_fragment_maps:hu,normal_pars_fragment:du,normal_pars_vertex:fu,normal_vertex:pu,normalmap_pars_fragment:mu,clearcoat_normal_fragment_begin:gu,clearcoat_normal_fragment_maps:_u,clearcoat_pars_fragment:vu,iridescence_pars_fragment:xu,opaque_fragment:Su,packing:yu,premultiplied_alpha_fragment:Tu,project_vertex:Mu,dithering_fragment:Eu,dithering_pars_fragment:bu,roughnessmap_fragment:Au,roughnessmap_pars_fragment:wu,shadowmap_pars_fragment:Ru,shadowmap_pars_vertex:Cu,shadowmap_vertex:Pu,shadowmask_pars_fragment:Lu,skinbase_vertex:Du,skinning_pars_vertex:Uu,skinning_vertex:Iu,skinnormal_vertex:Nu,specularmap_fragment:Fu,specularmap_pars_fragment:Ou,tonemapping_fragment:zu,tonemapping_pars_fragment:Bu,transmission_fragment:Vu,transmission_pars_fragment:Hu,uv_pars_fragment:Gu,uv_pars_vertex:ku,uv_vertex:Wu,worldpos_vertex:Xu,background_vert:qu,background_frag:Yu,backgroundCube_vert:$u,backgroundCube_frag:ju,cube_vert:Zu,cube_frag:Ku,depth_vert:Ju,depth_frag:Qu,distanceRGBA_vert:th,distanceRGBA_frag:eh,equirect_vert:nh,equirect_frag:ih,linedashed_vert:rh,linedashed_frag:ah,meshbasic_vert:sh,meshbasic_frag:oh,meshlambert_vert:lh,meshlambert_frag:ch,meshmatcap_vert:uh,meshmatcap_frag:hh,meshnormal_vert:dh,meshnormal_frag:fh,meshphong_vert:ph,meshphong_frag:mh,meshphysical_vert:gh,meshphysical_frag:_h,meshtoon_vert:vh,meshtoon_frag:xh,points_vert:Sh,points_frag:yh,shadow_vert:Th,shadow_frag:Mh,sprite_vert:Eh,sprite_frag:bh},nt={common:{diffuse:{value:new kt(16777215)},opacity:{value:1},map:{value:null},mapTransform:{value:new Ct},alphaMap:{value:null},alphaMapTransform:{value:new Ct},alphaTest:{value:0}},specularmap:{specularMap:{value:null},specularMapTransform:{value:new Ct}},envmap:{envMap:{value:null},flipEnvMap:{value:-1},reflectivity:{value:1},ior:{value:1.5},refractionRatio:{value:.98}},aomap:{aoMap:{value:null},aoMapIntensity:{value:1},aoMapTransform:{value:new Ct}},lightmap:{lightMap:{value:null},lightMapIntensity:{value:1},lightMapTransform:{value:new Ct}},bumpmap:{bumpMap:{value:null},bumpMapTransform:{value:new Ct},bumpScale:{value:1}},normalmap:{normalMap:{value:null},normalMapTransform:{value:new Ct},normalScale:{value:new Wt(1,1)}},displacementmap:{displacementMap:{value:null},displacementMapTransform:{value:new Ct},displacementScale:{value:1},displacementBias:{value:0}},emissivemap:{emissiveMap:{value:null},emissiveMapTransform:{value:new Ct}},metalnessmap:{metalnessMap:{value:null},metalnessMapTransform:{value:new Ct}},roughnessmap:{roughnessMap:{value:null},roughnessMapTransform:{value:new Ct}},gradientmap:{gradientMap:{value:null}},fog:{fogDensity:{value:25e-5},fogNear:{value:1},fogFar:{value:2e3},fogColor:{value:new kt(16777215)}},lights:{ambientLightColor:{value:[]},lightProbe:{value:[]},directionalLights:{value:[],properties:{direction:{},color:{}}},directionalLightShadows:{value:[],properties:{shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{}}},directionalShadowMap:{value:[]},directionalShadowMatrix:{value:[]},spotLights:{value:[],properties:{color:{},position:{},direction:{},distance:{},coneCos:{},penumbraCos:{},decay:{}}},spotLightShadows:{value:[],properties:{shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{}}},spotLightMap:{value:[]},spotShadowMap:{value:[]},spotLightMatrix:{value:[]},pointLights:{value:[],properties:{color:{},position:{},decay:{},distance:{}}},pointLightShadows:{value:[],properties:{shadowBias:{},shadowNormalBias:{},shadowRadius:{},shadowMapSize:{},shadowCameraNear:{},shadowCameraFar:{}}},pointShadowMap:{value:[]},pointShadowMatrix:{value:[]},hemisphereLights:{value:[],properties:{direction:{},skyColor:{},groundColor:{}}},rectAreaLights:{value:[],properties:{color:{},position:{},width:{},height:{}}},ltc_1:{value:null},ltc_2:{value:null}},points:{diffuse:{value:new kt(16777215)},opacity:{value:1},size:{value:1},scale:{value:1},map:{value:null},alphaMap:{value:null},alphaMapTransform:{value:new Ct},alphaTest:{value:0},uvTransform:{value:new Ct}},sprite:{diffuse:{value:new kt(16777215)},opacity:{value:1},center:{value:new Wt(.5,.5)},rotation:{value:0},map:{value:null},mapTransform:{value:new Ct},alphaMap:{value:null},alphaMapTransform:{value:new Ct},alphaTest:{value:0}}},Oe={basic:{uniforms:ge([nt.common,nt.specularmap,nt.envmap,nt.aomap,nt.lightmap,nt.fog]),vertexShader:Dt.meshbasic_vert,fragmentShader:Dt.meshbasic_frag},lambert:{uniforms:ge([nt.common,nt.specularmap,nt.envmap,nt.aomap,nt.lightmap,nt.emissivemap,nt.bumpmap,nt.normalmap,nt.displacementmap,nt.fog,nt.lights,{emissive:{value:new kt(0)}}]),vertexShader:Dt.meshlambert_vert,fragmentShader:Dt.meshlambert_frag},phong:{uniforms:ge([nt.common,nt.specularmap,nt.envmap,nt.aomap,nt.lightmap,nt.emissivemap,nt.bumpmap,nt.normalmap,nt.displacementmap,nt.fog,nt.lights,{emissive:{value:new kt(0)},specular:{value:new kt(1118481)},shininess:{value:30}}]),vertexShader:Dt.meshphong_vert,fragmentShader:Dt.meshphong_frag},standard:{uniforms:ge([nt.common,nt.envmap,nt.aomap,nt.lightmap,nt.emissivemap,nt.bumpmap,nt.normalmap,nt.displacementmap,nt.roughnessmap,nt.metalnessmap,nt.fog,nt.lights,{emissive:{value:new kt(0)},roughness:{value:1},metalness:{value:0},envMapIntensity:{value:1}}]),vertexShader:Dt.meshphysical_vert,fragmentShader:Dt.meshphysical_frag},toon:{uniforms:ge([nt.common,nt.aomap,nt.lightmap,nt.emissivemap,nt.bumpmap,nt.normalmap,nt.displacementmap,nt.gradientmap,nt.fog,nt.lights,{emissive:{value:new kt(0)}}]),vertexShader:Dt.meshtoon_vert,fragmentShader:Dt.meshtoon_frag},matcap:{uniforms:ge([nt.common,nt.bumpmap,nt.normalmap,nt.displacementmap,nt.fog,{matcap:{value:null}}]),vertexShader:Dt.meshmatcap_vert,fragmentShader:Dt.meshmatcap_frag},points:{uniforms:ge([nt.points,nt.fog]),vertexShader:Dt.points_vert,fragmentShader:Dt.points_frag},dashed:{uniforms:ge([nt.common,nt.fog,{scale:{value:1},dashSize:{value:1},totalSize:{value:2}}]),vertexShader:Dt.linedashed_vert,fragmentShader:Dt.linedashed_frag},depth:{uniforms:ge([nt.common,nt.displacementmap]),vertexShader:Dt.depth_vert,fragmentShader:Dt.depth_frag},normal:{uniforms:ge([nt.common,nt.bumpmap,nt.normalmap,nt.displacementmap,{opacity:{value:1}}]),vertexShader:Dt.meshnormal_vert,fragmentShader:Dt.meshnormal_frag},sprite:{uniforms:ge([nt.sprite,nt.fog]),vertexShader:Dt.sprite_vert,fragmentShader:Dt.sprite_frag},background:{uniforms:{uvTransform:{value:new Ct},t2D:{value:null},backgroundIntensity:{value:1}},vertexShader:Dt.background_vert,fragmentShader:Dt.background_frag},backgroundCube:{uniforms:{envMap:{value:null},flipEnvMap:{value:-1},backgroundBlurriness:{value:0},backgroundIntensity:{value:1}},vertexShader:Dt.backgroundCube_vert,fragmentShader:Dt.backgroundCube_frag},cube:{uniforms:{tCube:{value:null},tFlip:{value:-1},opacity:{value:1}},vertexShader:Dt.cube_vert,fragmentShader:Dt.cube_frag},equirect:{uniforms:{tEquirect:{value:null}},vertexShader:Dt.equirect_vert,fragmentShader:Dt.equirect_frag},distanceRGBA:{uniforms:ge([nt.common,nt.displacementmap,{referencePosition:{value:new L},nearDistance:{value:1},farDistance:{value:1e3}}]),vertexShader:Dt.distanceRGBA_vert,fragmentShader:Dt.distanceRGBA_frag},shadow:{uniforms:ge([nt.lights,nt.fog,{color:{value:new kt(0)},opacity:{value:1}}]),vertexShader:Dt.shadow_vert,fragmentShader:Dt.shadow_frag}};Oe.physical={uniforms:ge([Oe.standard.uniforms,{clearcoat:{value:0},clearcoatMap:{value:null},clearcoatMapTransform:{value:new Ct},clearcoatNormalMap:{value:null},clearcoatNormalMapTransform:{value:new Ct},clearcoatNormalScale:{value:new Wt(1,1)},clearcoatRoughness:{value:0},clearcoatRoughnessMap:{value:null},clearcoatRoughnessMapTransform:{value:new Ct},iridescence:{value:0},iridescenceMap:{value:null},iridescenceMapTransform:{value:new Ct},iridescenceIOR:{value:1.3},iridescenceThicknessMinimum:{value:100},iridescenceThicknessMaximum:{value:400},iridescenceThicknessMap:{value:null},iridescenceThicknessMapTransform:{value:new Ct},sheen:{value:0},sheenColor:{value:new kt(0)},sheenColorMap:{value:null},sheenColorMapTransform:{value:new Ct},sheenRoughness:{value:1},sheenRoughnessMap:{value:null},sheenRoughnessMapTransform:{value:new Ct},transmission:{value:0},transmissionMap:{value:null},transmissionMapTransform:{value:new Ct},transmissionSamplerSize:{value:new Wt},transmissionSamplerMap:{value:null},thickness:{value:0},thicknessMap:{value:null},thicknessMapTransform:{value:new Ct},attenuationDistance:{value:0},attenuationColor:{value:new kt(0)},specularColor:{value:new kt(1,1,1)},specularColorMap:{value:null},specularColorMapTransform:{value:new Ct},specularIntensity:{value:1},specularIntensityMap:{value:null},specularIntensityMapTransform:{value:new Ct},anisotropyVector:{value:new Wt},anisotropyMap:{value:null},anisotropyMapTransform:{value:new Ct}}]),vertexShader:Dt.meshphysical_vert,fragmentShader:Dt.meshphysical_frag};const Fi={r:0,b:0,g:0};function Ah(i,t,e,n,r,a,o){const s=new kt(0);let l=a===!0?0:1,c,u,d=null,f=0,m=null;function v(p,h){let E=!1,T=h.isScene===!0?h.background:null;T&&T.isTexture&&(T=(h.backgroundBlurriness>0?e:t).get(T)),T===null?_(s,l):T&&T.isColor&&(_(T,1),E=!0);const b=i.xr.getEnvironmentBlendMode();b==="additive"?n.buffers.color.setClear(0,0,0,1,o):b==="alpha-blend"&&n.buffers.color.setClear(0,0,0,0,o),(i.autoClear||E)&&i.clear(i.autoClearColor,i.autoClearDepth,i.autoClearStencil),T&&(T.isCubeTexture||T.mapping===qi)?(u===void 0&&(u=new Ze(new fi(1,1,1),new hn({name:"BackgroundCubeMaterial",uniforms:jn(Oe.backgroundCube.uniforms),vertexShader:Oe.backgroundCube.vertexShader,fragmentShader:Oe.backgroundCube.fragmentShader,side:xe,depthTest:!1,depthWrite:!1,fog:!1})),u.geometry.deleteAttribute("normal"),u.geometry.deleteAttribute("uv"),u.onBeforeRender=function(D,R,w){this.matrixWorld.copyPosition(w.matrixWorld)},Object.defineProperty(u.material,"envMap",{get:function(){return this.uniforms.envMap.value}}),r.update(u)),u.material.uniforms.envMap.value=T,u.material.uniforms.flipEnvMap.value=T.isCubeTexture&&T.isRenderTargetTexture===!1?-1:1,u.material.uniforms.backgroundBlurriness.value=h.backgroundBlurriness,u.material.uniforms.backgroundIntensity.value=h.backgroundIntensity,u.material.toneMapped=Gt.getTransfer(T.colorSpace)!==$t,(d!==T||f!==T.version||m!==i.toneMapping)&&(u.material.needsUpdate=!0,d=T,f=T.version,m=i.toneMapping),u.layers.enableAll(),p.unshift(u,u.geometry,u.material,0,0,null)):T&&T.isTexture&&(c===void 0&&(c=new Ze(new jr(2,2),new hn({name:"BackgroundMaterial",uniforms:jn(Oe.background.uniforms),vertexShader:Oe.background.vertexShader,fragmentShader:Oe.background.fragmentShader,side:un,depthTest:!1,depthWrite:!1,fog:!1})),c.geometry.deleteAttribute("normal"),Object.defineProperty(c.material,"map",{get:function(){return this.uniforms.t2D.value}}),r.update(c)),c.material.uniforms.t2D.value=T,c.material.uniforms.backgroundIntensity.value=h.backgroundIntensity,c.material.toneMapped=Gt.getTransfer(T.colorSpace)!==$t,T.matrixAutoUpdate===!0&&T.updateMatrix(),c.material.uniforms.uvTransform.value.copy(T.matrix),(d!==T||f!==T.version||m!==i.toneMapping)&&(c.material.needsUpdate=!0,d=T,f=T.version,m=i.toneMapping),c.layers.enableAll(),p.unshift(c,c.geometry,c.material,0,0,null))}function _(p,h){p.getRGB(Fi,Zs(i)),n.buffers.color.setClear(Fi.r,Fi.g,Fi.b,h,o)}return{getClearColor:function(){return s},setClearColor:function(p,h=1){s.set(p),l=h,_(s,l)},getClearAlpha:function(){return l},setClearAlpha:function(p){l=p,_(s,l)},render:v}}function wh(i,t,e,n){const r=i.getParameter(i.MAX_VERTEX_ATTRIBS),a=n.isWebGL2?null:t.get("OES_vertex_array_object"),o=n.isWebGL2||a!==null,s={},l=p(null);let c=l,u=!1;function d(C,z,V,X,G){let W=!1;if(o){const q=_(X,V,z);c!==q&&(c=q,m(c.object)),W=h(C,X,V,G),W&&E(C,X,V,G)}else{const q=z.wireframe===!0;(c.geometry!==X.id||c.program!==V.id||c.wireframe!==q)&&(c.geometry=X.id,c.program=V.id,c.wireframe=q,W=!0)}G!==null&&e.update(G,i.ELEMENT_ARRAY_BUFFER),(W||u)&&(u=!1,Z(C,z,V,X),G!==null&&i.bindBuffer(i.ELEMENT_ARRAY_BUFFER,e.get(G).buffer))}function f(){return n.isWebGL2?i.createVertexArray():a.createVertexArrayOES()}function m(C){return n.isWebGL2?i.bindVertexArray(C):a.bindVertexArrayOES(C)}function v(C){return n.isWebGL2?i.deleteVertexArray(C):a.deleteVertexArrayOES(C)}function _(C,z,V){const X=V.wireframe===!0;let G=s[C.id];G===void 0&&(G={},s[C.id]=G);let W=G[z.id];W===void 0&&(W={},G[z.id]=W);let q=W[X];return q===void 0&&(q=p(f()),W[X]=q),q}function p(C){const z=[],V=[],X=[];for(let G=0;G<r;G++)z[G]=0,V[G]=0,X[G]=0;return{geometry:null,program:null,wireframe:!1,newAttributes:z,enabledAttributes:V,attributeDivisors:X,object:C,attributes:{},index:null}}function h(C,z,V,X){const G=c.attributes,W=z.attributes;let q=0;const Q=V.getAttributes();for(const tt in Q)if(Q[tt].location>=0){const Y=G[tt];let ot=W[tt];if(ot===void 0&&(tt==="instanceMatrix"&&C.instanceMatrix&&(ot=C.instanceMatrix),tt==="instanceColor"&&C.instanceColor&&(ot=C.instanceColor)),Y===void 0||Y.attribute!==ot||ot&&Y.data!==ot.data)return!0;q++}return c.attributesNum!==q||c.index!==X}function E(C,z,V,X){const G={},W=z.attributes;let q=0;const Q=V.getAttributes();for(const tt in Q)if(Q[tt].location>=0){let Y=W[tt];Y===void 0&&(tt==="instanceMatrix"&&C.instanceMatrix&&(Y=C.instanceMatrix),tt==="instanceColor"&&C.instanceColor&&(Y=C.instanceColor));const ot={};ot.attribute=Y,Y&&Y.data&&(ot.data=Y.data),G[tt]=ot,q++}c.attributes=G,c.attributesNum=q,c.index=X}function T(){const C=c.newAttributes;for(let z=0,V=C.length;z<V;z++)C[z]=0}function b(C){D(C,0)}function D(C,z){const V=c.newAttributes,X=c.enabledAttributes,G=c.attributeDivisors;V[C]=1,X[C]===0&&(i.enableVertexAttribArray(C),X[C]=1),G[C]!==z&&((n.isWebGL2?i:t.get("ANGLE_instanced_arrays"))[n.isWebGL2?"vertexAttribDivisor":"vertexAttribDivisorANGLE"](C,z),G[C]=z)}function R(){const C=c.newAttributes,z=c.enabledAttributes;for(let V=0,X=z.length;V<X;V++)z[V]!==C[V]&&(i.disableVertexAttribArray(V),z[V]=0)}function w(C,z,V,X,G,W,q){q===!0?i.vertexAttribIPointer(C,z,V,G,W):i.vertexAttribPointer(C,z,V,X,G,W)}function Z(C,z,V,X){if(n.isWebGL2===!1&&(C.isInstancedMesh||X.isInstancedBufferGeometry)&&t.get("ANGLE_instanced_arrays")===null)return;T();const G=X.attributes,W=V.getAttributes(),q=z.defaultAttributeValues;for(const Q in W){const tt=W[Q];if(tt.location>=0){let B=G[Q];if(B===void 0&&(Q==="instanceMatrix"&&C.instanceMatrix&&(B=C.instanceMatrix),Q==="instanceColor"&&C.instanceColor&&(B=C.instanceColor)),B!==void 0){const Y=B.normalized,ot=B.itemSize,mt=e.get(B);if(mt===void 0)continue;const pt=mt.buffer,wt=mt.type,Pt=mt.bytesPerElement,yt=n.isWebGL2===!0&&(wt===i.INT||wt===i.UNSIGNED_INT||B.gpuType===Ds);if(B.isInterleavedBufferAttribute){const Bt=B.data,U=Bt.stride,fe=B.offset;if(Bt.isInstancedInterleavedBuffer){for(let _t=0;_t<tt.locationSize;_t++)D(tt.location+_t,Bt.meshPerAttribute);C.isInstancedMesh!==!0&&X._maxInstanceCount===void 0&&(X._maxInstanceCount=Bt.meshPerAttribute*Bt.count)}else for(let _t=0;_t<tt.locationSize;_t++)b(tt.location+_t);i.bindBuffer(i.ARRAY_BUFFER,pt);for(let _t=0;_t<tt.locationSize;_t++)w(tt.location+_t,ot/tt.locationSize,wt,Y,U*Pt,(fe+ot/tt.locationSize*_t)*Pt,yt)}else{if(B.isInstancedBufferAttribute){for(let Bt=0;Bt<tt.locationSize;Bt++)D(tt.location+Bt,B.meshPerAttribute);C.isInstancedMesh!==!0&&X._maxInstanceCount===void 0&&(X._maxInstanceCount=B.meshPerAttribute*B.count)}else for(let Bt=0;Bt<tt.locationSize;Bt++)b(tt.location+Bt);i.bindBuffer(i.ARRAY_BUFFER,pt);for(let Bt=0;Bt<tt.locationSize;Bt++)w(tt.location+Bt,ot/tt.locationSize,wt,Y,ot*Pt,ot/tt.locationSize*Bt*Pt,yt)}}else if(q!==void 0){const Y=q[Q];if(Y!==void 0)switch(Y.length){case 2:i.vertexAttrib2fv(tt.location,Y);break;case 3:i.vertexAttrib3fv(tt.location,Y);break;case 4:i.vertexAttrib4fv(tt.location,Y);break;default:i.vertexAttrib1fv(tt.location,Y)}}}}R()}function y(){k();for(const C in s){const z=s[C];for(const V in z){const X=z[V];for(const G in X)v(X[G].object),delete X[G];delete z[V]}delete s[C]}}function M(C){if(s[C.id]===void 0)return;const z=s[C.id];for(const V in z){const X=z[V];for(const G in X)v(X[G].object),delete X[G];delete z[V]}delete s[C.id]}function H(C){for(const z in s){const V=s[z];if(V[C.id]===void 0)continue;const X=V[C.id];for(const G in X)v(X[G].object),delete X[G];delete V[C.id]}}function k(){it(),u=!0,c!==l&&(c=l,m(c.object))}function it(){l.geometry=null,l.program=null,l.wireframe=!1}return{setup:d,reset:k,resetDefaultState:it,dispose:y,releaseStatesOfGeometry:M,releaseStatesOfProgram:H,initAttributes:T,enableAttribute:b,disableUnusedAttributes:R}}function Rh(i,t,e,n){const r=n.isWebGL2;let a;function o(u){a=u}function s(u,d){i.drawArrays(a,u,d),e.update(d,a,1)}function l(u,d,f){if(f===0)return;let m,v;if(r)m=i,v="drawArraysInstanced";else if(m=t.get("ANGLE_instanced_arrays"),v="drawArraysInstancedANGLE",m===null){console.error("THREE.WebGLBufferRenderer: using THREE.InstancedBufferGeometry but hardware does not support extension ANGLE_instanced_arrays.");return}m[v](a,u,d,f),e.update(d,a,f)}function c(u,d,f){if(f===0)return;const m=t.get("WEBGL_multi_draw");if(m===null)for(let v=0;v<f;v++)this.render(u[v],d[v]);else{m.multiDrawArraysWEBGL(a,u,0,d,0,f);let v=0;for(let _=0;_<f;_++)v+=d[_];e.update(v,a,1)}}this.setMode=o,this.render=s,this.renderInstances=l,this.renderMultiDraw=c}function Ch(i,t,e){let n;function r(){if(n!==void 0)return n;if(t.has("EXT_texture_filter_anisotropic")===!0){const w=t.get("EXT_texture_filter_anisotropic");n=i.getParameter(w.MAX_TEXTURE_MAX_ANISOTROPY_EXT)}else n=0;return n}function a(w){if(w==="highp"){if(i.getShaderPrecisionFormat(i.VERTEX_SHADER,i.HIGH_FLOAT).precision>0&&i.getShaderPrecisionFormat(i.FRAGMENT_SHADER,i.HIGH_FLOAT).precision>0)return"highp";w="mediump"}return w==="mediump"&&i.getShaderPrecisionFormat(i.VERTEX_SHADER,i.MEDIUM_FLOAT).precision>0&&i.getShaderPrecisionFormat(i.FRAGMENT_SHADER,i.MEDIUM_FLOAT).precision>0?"mediump":"lowp"}const o=typeof WebGL2RenderingContext<"u"&&i.constructor.name==="WebGL2RenderingContext";let s=e.precision!==void 0?e.precision:"highp";const l=a(s);l!==s&&(console.warn("THREE.WebGLRenderer:",s,"not supported, using",l,"instead."),s=l);const c=o||t.has("WEBGL_draw_buffers"),u=e.logarithmicDepthBuffer===!0,d=i.getParameter(i.MAX_TEXTURE_IMAGE_UNITS),f=i.getParameter(i.MAX_VERTEX_TEXTURE_IMAGE_UNITS),m=i.getParameter(i.MAX_TEXTURE_SIZE),v=i.getParameter(i.MAX_CUBE_MAP_TEXTURE_SIZE),_=i.getParameter(i.MAX_VERTEX_ATTRIBS),p=i.getParameter(i.MAX_VERTEX_UNIFORM_VECTORS),h=i.getParameter(i.MAX_VARYING_VECTORS),E=i.getParameter(i.MAX_FRAGMENT_UNIFORM_VECTORS),T=f>0,b=o||t.has("OES_texture_float"),D=T&&b,R=o?i.getParameter(i.MAX_SAMPLES):0;return{isWebGL2:o,drawBuffers:c,getMaxAnisotropy:r,getMaxPrecision:a,precision:s,logarithmicDepthBuffer:u,maxTextures:d,maxVertexTextures:f,maxTextureSize:m,maxCubemapSize:v,maxAttributes:_,maxVertexUniforms:p,maxVaryings:h,maxFragmentUniforms:E,vertexTextures:T,floatFragmentTextures:b,floatVertexTextures:D,maxSamples:R}}function Ph(i){const t=this;let e=null,n=0,r=!1,a=!1;const o=new xn,s=new Ct,l={value:null,needsUpdate:!1};this.uniform=l,this.numPlanes=0,this.numIntersection=0,this.init=function(d,f){const m=d.length!==0||f||n!==0||r;return r=f,n=d.length,m},this.beginShadows=function(){a=!0,u(null)},this.endShadows=function(){a=!1},this.setGlobalState=function(d,f){e=u(d,f,0)},this.setState=function(d,f,m){const v=d.clippingPlanes,_=d.clipIntersection,p=d.clipShadows,h=i.get(d);if(!r||v===null||v.length===0||a&&!p)a?u(null):c();else{const E=a?0:n,T=E*4;let b=h.clippingState||null;l.value=b,b=u(v,f,T,m);for(let D=0;D!==T;++D)b[D]=e[D];h.clippingState=b,this.numIntersection=_?this.numPlanes:0,this.numPlanes+=E}};function c(){l.value!==e&&(l.value=e,l.needsUpdate=n>0),t.numPlanes=n,t.numIntersection=0}function u(d,f,m,v){const _=d!==null?d.length:0;let p=null;if(_!==0){if(p=l.value,v!==!0||p===null){const h=m+_*4,E=f.matrixWorldInverse;s.getNormalMatrix(E),(p===null||p.length<h)&&(p=new Float32Array(h));for(let T=0,b=m;T!==_;++T,b+=4)o.copy(d[T]).applyMatrix4(E,s),o.normal.toArray(p,b),p[b+3]=o.constant}l.value=p,l.needsUpdate=!0}return t.numPlanes=_,t.numIntersection=0,p}}function Lh(i){let t=new WeakMap;function e(o,s){return s===Fr?o.mapping=qn:s===Or&&(o.mapping=Yn),o}function n(o){if(o&&o.isTexture){const s=o.mapping;if(s===Fr||s===Or)if(t.has(o)){const l=t.get(o).texture;return e(l,o.mapping)}else{const l=o.image;if(l&&l.height>0){const c=new kl(l.height/2);return c.fromEquirectangularTexture(i,o),t.set(o,c),o.addEventListener("dispose",r),e(c.texture,o.mapping)}else return null}}return o}function r(o){const s=o.target;s.removeEventListener("dispose",r);const l=t.get(s);l!==void 0&&(t.delete(s),l.dispose())}function a(){t=new WeakMap}return{get:n,dispose:a}}class eo extends Ks{constructor(t=-1,e=1,n=1,r=-1,a=.1,o=2e3){super(),this.isOrthographicCamera=!0,this.type="OrthographicCamera",this.zoom=1,this.view=null,this.left=t,this.right=e,this.top=n,this.bottom=r,this.near=a,this.far=o,this.updateProjectionMatrix()}copy(t,e){return super.copy(t,e),this.left=t.left,this.right=t.right,this.top=t.top,this.bottom=t.bottom,this.near=t.near,this.far=t.far,this.zoom=t.zoom,this.view=t.view===null?null:Object.assign({},t.view),this}setViewOffset(t,e,n,r,a,o){this.view===null&&(this.view={enabled:!0,fullWidth:1,fullHeight:1,offsetX:0,offsetY:0,width:1,height:1}),this.view.enabled=!0,this.view.fullWidth=t,this.view.fullHeight=e,this.view.offsetX=n,this.view.offsetY=r,this.view.width=a,this.view.height=o,this.updateProjectionMatrix()}clearViewOffset(){this.view!==null&&(this.view.enabled=!1),this.updateProjectionMatrix()}updateProjectionMatrix(){const t=(this.right-this.left)/(2*this.zoom),e=(this.top-this.bottom)/(2*this.zoom),n=(this.right+this.left)/2,r=(this.top+this.bottom)/2;let a=n-t,o=n+t,s=r+e,l=r-e;if(this.view!==null&&this.view.enabled){const c=(this.right-this.left)/this.view.fullWidth/this.zoom,u=(this.top-this.bottom)/this.view.fullHeight/this.zoom;a+=c*this.view.offsetX,o=a+c*this.view.width,s-=u*this.view.offsetY,l=s-u*this.view.height}this.projectionMatrix.makeOrthographic(a,o,s,l,this.near,this.far,this.coordinateSystem),this.projectionMatrixInverse.copy(this.projectionMatrix).invert()}toJSON(t){const e=super.toJSON(t);return e.object.zoom=this.zoom,e.object.left=this.left,e.object.right=this.right,e.object.top=this.top,e.object.bottom=this.bottom,e.object.near=this.near,e.object.far=this.far,this.view!==null&&(e.object.view=Object.assign({},this.view)),e}}const Gn=4,rs=[.125,.215,.35,.446,.526,.582],Tn=20,Ar=new eo,as=new kt;let wr=null,Rr=0,Cr=0;const Sn=(1+Math.sqrt(5))/2,Hn=1/Sn,ss=[new L(1,1,1),new L(-1,1,1),new L(1,1,-1),new L(-1,1,-1),new L(0,Sn,Hn),new L(0,Sn,-Hn),new L(Hn,0,Sn),new L(-Hn,0,Sn),new L(Sn,Hn,0),new L(-Sn,Hn,0)];class os{constructor(t){this._renderer=t,this._pingPongRenderTarget=null,this._lodMax=0,this._cubeSize=0,this._lodPlanes=[],this._sizeLods=[],this._sigmas=[],this._blurMaterial=null,this._cubemapMaterial=null,this._equirectMaterial=null,this._compileMaterial(this._blurMaterial)}fromScene(t,e=0,n=.1,r=100){wr=this._renderer.getRenderTarget(),Rr=this._renderer.getActiveCubeFace(),Cr=this._renderer.getActiveMipmapLevel(),this._setSize(256);const a=this._allocateTargets();return a.depthBuffer=!0,this._sceneToCubeUV(t,n,r,a),e>0&&this._blur(a,0,0,e),this._applyPMREM(a),this._cleanup(a),a}fromEquirectangular(t,e=null){return this._fromTexture(t,e)}fromCubemap(t,e=null){return this._fromTexture(t,e)}compileCubemapShader(){this._cubemapMaterial===null&&(this._cubemapMaterial=us(),this._compileMaterial(this._cubemapMaterial))}compileEquirectangularShader(){this._equirectMaterial===null&&(this._equirectMaterial=cs(),this._compileMaterial(this._equirectMaterial))}dispose(){this._dispose(),this._cubemapMaterial!==null&&this._cubemapMaterial.dispose(),this._equirectMaterial!==null&&this._equirectMaterial.dispose()}_setSize(t){this._lodMax=Math.floor(Math.log2(t)),this._cubeSize=Math.pow(2,this._lodMax)}_dispose(){this._blurMaterial!==null&&this._blurMaterial.dispose(),this._pingPongRenderTarget!==null&&this._pingPongRenderTarget.dispose();for(let t=0;t<this._lodPlanes.length;t++)this._lodPlanes[t].dispose()}_cleanup(t){this._renderer.setRenderTarget(wr,Rr,Cr),t.scissorTest=!1,Oi(t,0,0,t.width,t.height)}_fromTexture(t,e){t.mapping===qn||t.mapping===Yn?this._setSize(t.image.length===0?16:t.image[0].width||t.image[0].image.width):this._setSize(t.image.width/4),wr=this._renderer.getRenderTarget(),Rr=this._renderer.getActiveCubeFace(),Cr=this._renderer.getActiveMipmapLevel();const n=e||this._allocateTargets();return this._textureToCubeUV(t,n),this._applyPMREM(n),this._cleanup(n),n}_allocateTargets(){const t=3*Math.max(this._cubeSize,112),e=4*this._cubeSize,n={magFilter:Re,minFilter:Re,generateMipmaps:!1,type:oi,format:Ce,colorSpace:Je,depthBuffer:!1},r=ls(t,e,n);if(this._pingPongRenderTarget===null||this._pingPongRenderTarget.width!==t||this._pingPongRenderTarget.height!==e){this._pingPongRenderTarget!==null&&this._dispose(),this._pingPongRenderTarget=ls(t,e,n);const{_lodMax:a}=this;({sizeLods:this._sizeLods,lodPlanes:this._lodPlanes,sigmas:this._sigmas}=Dh(a)),this._blurMaterial=Uh(a,t,e)}return r}_compileMaterial(t){const e=new Ze(this._lodPlanes[0],t);this._renderer.compile(e,Ar)}_sceneToCubeUV(t,e,n,r){const s=new Ne(90,1,e,n),l=[1,-1,1,1,1,1],c=[1,1,1,-1,-1,-1],u=this._renderer,d=u.autoClear,f=u.toneMapping;u.getClearColor(as),u.toneMapping=ln,u.autoClear=!1;const m=new Ys({name:"PMREM.Background",side:xe,depthWrite:!1,depthTest:!1}),v=new Ze(new fi,m);let _=!1;const p=t.background;p?p.isColor&&(m.color.copy(p),t.background=null,_=!0):(m.color.copy(as),_=!0);for(let h=0;h<6;h++){const E=h%3;E===0?(s.up.set(0,l[h],0),s.lookAt(c[h],0,0)):E===1?(s.up.set(0,0,l[h]),s.lookAt(0,c[h],0)):(s.up.set(0,l[h],0),s.lookAt(0,0,c[h]));const T=this._cubeSize;Oi(r,E*T,h>2?T:0,T,T),u.setRenderTarget(r),_&&u.render(v,s),u.render(t,s)}v.geometry.dispose(),v.material.dispose(),u.toneMapping=f,u.autoClear=d,t.background=p}_textureToCubeUV(t,e){const n=this._renderer,r=t.mapping===qn||t.mapping===Yn;r?(this._cubemapMaterial===null&&(this._cubemapMaterial=us()),this._cubemapMaterial.uniforms.flipEnvMap.value=t.isRenderTargetTexture===!1?-1:1):this._equirectMaterial===null&&(this._equirectMaterial=cs());const a=r?this._cubemapMaterial:this._equirectMaterial,o=new Ze(this._lodPlanes[0],a),s=a.uniforms;s.envMap.value=t;const l=this._cubeSize;Oi(e,0,0,3*l,2*l),n.setRenderTarget(e),n.render(o,Ar)}_applyPMREM(t){const e=this._renderer,n=e.autoClear;e.autoClear=!1;for(let r=1;r<this._lodPlanes.length;r++){const a=Math.sqrt(this._sigmas[r]*this._sigmas[r]-this._sigmas[r-1]*this._sigmas[r-1]),o=ss[(r-1)%ss.length];this._blur(t,r-1,r,a,o)}e.autoClear=n}_blur(t,e,n,r,a){const o=this._pingPongRenderTarget;this._halfBlur(t,o,e,n,r,"latitudinal",a),this._halfBlur(o,t,n,n,r,"longitudinal",a)}_halfBlur(t,e,n,r,a,o,s){const l=this._renderer,c=this._blurMaterial;o!=="latitudinal"&&o!=="longitudinal"&&console.error("blur direction must be either latitudinal or longitudinal!");const u=3,d=new Ze(this._lodPlanes[r],c),f=c.uniforms,m=this._sizeLods[n]-1,v=isFinite(a)?Math.PI/(2*m):2*Math.PI/(2*Tn-1),_=a/v,p=isFinite(a)?1+Math.floor(u*_):Tn;p>Tn&&console.warn(`sigmaRadians, ${a}, is too large and will clip, as it requested ${p} samples when the maximum is set to ${Tn}`);const h=[];let E=0;for(let w=0;w<Tn;++w){const Z=w/_,y=Math.exp(-Z*Z/2);h.push(y),w===0?E+=y:w<p&&(E+=2*y)}for(let w=0;w<h.length;w++)h[w]=h[w]/E;f.envMap.value=t.texture,f.samples.value=p,f.weights.value=h,f.latitudinal.value=o==="latitudinal",s&&(f.poleAxis.value=s);const{_lodMax:T}=this;f.dTheta.value=v,f.mipInt.value=T-n;const b=this._sizeLods[r],D=3*b*(r>T-Gn?r-T+Gn:0),R=4*(this._cubeSize-b);Oi(e,D,R,3*b,2*b),l.setRenderTarget(e),l.render(d,Ar)}}function Dh(i){const t=[],e=[],n=[];let r=i;const a=i-Gn+1+rs.length;for(let o=0;o<a;o++){const s=Math.pow(2,r);e.push(s);let l=1/s;o>i-Gn?l=rs[o-i+Gn-1]:o===0&&(l=0),n.push(l);const c=1/(s-2),u=-c,d=1+c,f=[u,u,d,u,d,d,u,u,d,d,u,d],m=6,v=6,_=3,p=2,h=1,E=new Float32Array(_*v*m),T=new Float32Array(p*v*m),b=new Float32Array(h*v*m);for(let R=0;R<m;R++){const w=R%3*2/3-1,Z=R>2?0:-1,y=[w,Z,0,w+2/3,Z,0,w+2/3,Z+1,0,w,Z,0,w+2/3,Z+1,0,w,Z+1,0];E.set(y,_*v*R),T.set(f,p*v*R);const M=[R,R,R,R,R,R];b.set(M,h*v*R)}const D=new dn;D.setAttribute("position",new ze(E,_)),D.setAttribute("uv",new ze(T,p)),D.setAttribute("faceIndex",new ze(b,h)),t.push(D),r>Gn&&r--}return{lodPlanes:t,sizeLods:e,sigmas:n}}function ls(i,t,e){const n=new Qe(i,t,e);return n.texture.mapping=qi,n.texture.name="PMREM.cubeUv",n.scissorTest=!0,n}function Oi(i,t,e,n,r){i.viewport.set(t,e,n,r),i.scissor.set(t,e,n,r)}function Uh(i,t,e){const n=new Float32Array(Tn),r=new L(0,1,0);return new hn({name:"SphericalGaussianBlur",defines:{n:Tn,CUBEUV_TEXEL_WIDTH:1/t,CUBEUV_TEXEL_HEIGHT:1/e,CUBEUV_MAX_MIP:`${i}.0`},uniforms:{envMap:{value:null},samples:{value:1},weights:{value:n},latitudinal:{value:!1},dTheta:{value:0},mipInt:{value:0},poleAxis:{value:r}},vertexShader:Zr(),fragmentShader:`

			precision mediump float;
			precision mediump int;

			varying vec3 vOutputDirection;

			uniform sampler2D envMap;
			uniform int samples;
			uniform float weights[ n ];
			uniform bool latitudinal;
			uniform float dTheta;
			uniform float mipInt;
			uniform vec3 poleAxis;

			#define ENVMAP_TYPE_CUBE_UV
			#include <cube_uv_reflection_fragment>

			vec3 getSample( float theta, vec3 axis ) {

				float cosTheta = cos( theta );
				// Rodrigues' axis-angle rotation
				vec3 sampleDirection = vOutputDirection * cosTheta
					+ cross( axis, vOutputDirection ) * sin( theta )
					+ axis * dot( axis, vOutputDirection ) * ( 1.0 - cosTheta );

				return bilinearCubeUV( envMap, sampleDirection, mipInt );

			}

			void main() {

				vec3 axis = latitudinal ? poleAxis : cross( poleAxis, vOutputDirection );

				if ( all( equal( axis, vec3( 0.0 ) ) ) ) {

					axis = vec3( vOutputDirection.z, 0.0, - vOutputDirection.x );

				}

				axis = normalize( axis );

				gl_FragColor = vec4( 0.0, 0.0, 0.0, 1.0 );
				gl_FragColor.rgb += weights[ 0 ] * getSample( 0.0, axis );

				for ( int i = 1; i < n; i++ ) {

					if ( i >= samples ) {

						break;

					}

					float theta = dTheta * float( i );
					gl_FragColor.rgb += weights[ i ] * getSample( -1.0 * theta, axis );
					gl_FragColor.rgb += weights[ i ] * getSample( theta, axis );

				}

			}
		`,blending:on,depthTest:!1,depthWrite:!1})}function cs(){return new hn({name:"EquirectangularToCubeUV",uniforms:{envMap:{value:null}},vertexShader:Zr(),fragmentShader:`

			precision mediump float;
			precision mediump int;

			varying vec3 vOutputDirection;

			uniform sampler2D envMap;

			#include <common>

			void main() {

				vec3 outputDirection = normalize( vOutputDirection );
				vec2 uv = equirectUv( outputDirection );

				gl_FragColor = vec4( texture2D ( envMap, uv ).rgb, 1.0 );

			}
		`,blending:on,depthTest:!1,depthWrite:!1})}function us(){return new hn({name:"CubemapToCubeUV",uniforms:{envMap:{value:null},flipEnvMap:{value:-1}},vertexShader:Zr(),fragmentShader:`

			precision mediump float;
			precision mediump int;

			uniform float flipEnvMap;

			varying vec3 vOutputDirection;

			uniform samplerCube envMap;

			void main() {

				gl_FragColor = textureCube( envMap, vec3( flipEnvMap * vOutputDirection.x, vOutputDirection.yz ) );

			}
		`,blending:on,depthTest:!1,depthWrite:!1})}function Zr(){return`

		precision mediump float;
		precision mediump int;

		attribute float faceIndex;

		varying vec3 vOutputDirection;

		// RH coordinate system; PMREM face-indexing convention
		vec3 getDirection( vec2 uv, float face ) {

			uv = 2.0 * uv - 1.0;

			vec3 direction = vec3( uv, 1.0 );

			if ( face == 0.0 ) {

				direction = direction.zyx; // ( 1, v, u ) pos x

			} else if ( face == 1.0 ) {

				direction = direction.xzy;
				direction.xz *= -1.0; // ( -u, 1, -v ) pos y

			} else if ( face == 2.0 ) {

				direction.x *= -1.0; // ( -u, v, 1 ) pos z

			} else if ( face == 3.0 ) {

				direction = direction.zyx;
				direction.xz *= -1.0; // ( -1, v, -u ) neg x

			} else if ( face == 4.0 ) {

				direction = direction.xzy;
				direction.xy *= -1.0; // ( -u, -1, v ) neg y

			} else if ( face == 5.0 ) {

				direction.z *= -1.0; // ( u, v, -1 ) neg z

			}

			return direction;

		}

		void main() {

			vOutputDirection = getDirection( uv, faceIndex );
			gl_Position = vec4( position, 1.0 );

		}
	`}function Ih(i){let t=new WeakMap,e=null;function n(s){if(s&&s.isTexture){const l=s.mapping,c=l===Fr||l===Or,u=l===qn||l===Yn;if(c||u)if(s.isRenderTargetTexture&&s.needsPMREMUpdate===!0){s.needsPMREMUpdate=!1;let d=t.get(s);return e===null&&(e=new os(i)),d=c?e.fromEquirectangular(s,d):e.fromCubemap(s,d),t.set(s,d),d.texture}else{if(t.has(s))return t.get(s).texture;{const d=s.image;if(c&&d&&d.height>0||u&&d&&r(d)){e===null&&(e=new os(i));const f=c?e.fromEquirectangular(s):e.fromCubemap(s);return t.set(s,f),s.addEventListener("dispose",a),f.texture}else return null}}}return s}function r(s){let l=0;const c=6;for(let u=0;u<c;u++)s[u]!==void 0&&l++;return l===c}function a(s){const l=s.target;l.removeEventListener("dispose",a);const c=t.get(l);c!==void 0&&(t.delete(l),c.dispose())}function o(){t=new WeakMap,e!==null&&(e.dispose(),e=null)}return{get:n,dispose:o}}function Nh(i){const t={};function e(n){if(t[n]!==void 0)return t[n];let r;switch(n){case"WEBGL_depth_texture":r=i.getExtension("WEBGL_depth_texture")||i.getExtension("MOZ_WEBGL_depth_texture")||i.getExtension("WEBKIT_WEBGL_depth_texture");break;case"EXT_texture_filter_anisotropic":r=i.getExtension("EXT_texture_filter_anisotropic")||i.getExtension("MOZ_EXT_texture_filter_anisotropic")||i.getExtension("WEBKIT_EXT_texture_filter_anisotropic");break;case"WEBGL_compressed_texture_s3tc":r=i.getExtension("WEBGL_compressed_texture_s3tc")||i.getExtension("MOZ_WEBGL_compressed_texture_s3tc")||i.getExtension("WEBKIT_WEBGL_compressed_texture_s3tc");break;case"WEBGL_compressed_texture_pvrtc":r=i.getExtension("WEBGL_compressed_texture_pvrtc")||i.getExtension("WEBKIT_WEBGL_compressed_texture_pvrtc");break;default:r=i.getExtension(n)}return t[n]=r,r}return{has:function(n){return e(n)!==null},init:function(n){n.isWebGL2?(e("EXT_color_buffer_float"),e("WEBGL_clip_cull_distance")):(e("WEBGL_depth_texture"),e("OES_texture_float"),e("OES_texture_half_float"),e("OES_texture_half_float_linear"),e("OES_standard_derivatives"),e("OES_element_index_uint"),e("OES_vertex_array_object"),e("ANGLE_instanced_arrays")),e("OES_texture_float_linear"),e("EXT_color_buffer_half_float"),e("WEBGL_multisampled_render_to_texture")},get:function(n){const r=e(n);return r===null&&console.warn("THREE.WebGLRenderer: "+n+" extension not supported."),r}}}function Fh(i,t,e,n){const r={},a=new WeakMap;function o(d){const f=d.target;f.index!==null&&t.remove(f.index);for(const v in f.attributes)t.remove(f.attributes[v]);for(const v in f.morphAttributes){const _=f.morphAttributes[v];for(let p=0,h=_.length;p<h;p++)t.remove(_[p])}f.removeEventListener("dispose",o),delete r[f.id];const m=a.get(f);m&&(t.remove(m),a.delete(f)),n.releaseStatesOfGeometry(f),f.isInstancedBufferGeometry===!0&&delete f._maxInstanceCount,e.memory.geometries--}function s(d,f){return r[f.id]===!0||(f.addEventListener("dispose",o),r[f.id]=!0,e.memory.geometries++),f}function l(d){const f=d.attributes;for(const v in f)t.update(f[v],i.ARRAY_BUFFER);const m=d.morphAttributes;for(const v in m){const _=m[v];for(let p=0,h=_.length;p<h;p++)t.update(_[p],i.ARRAY_BUFFER)}}function c(d){const f=[],m=d.index,v=d.attributes.position;let _=0;if(m!==null){const E=m.array;_=m.version;for(let T=0,b=E.length;T<b;T+=3){const D=E[T+0],R=E[T+1],w=E[T+2];f.push(D,R,R,w,w,D)}}else if(v!==void 0){const E=v.array;_=v.version;for(let T=0,b=E.length/3-1;T<b;T+=3){const D=T+0,R=T+1,w=T+2;f.push(D,R,R,w,w,D)}}else return;const p=new(Hs(f)?js:$s)(f,1);p.version=_;const h=a.get(d);h&&t.remove(h),a.set(d,p)}function u(d){const f=a.get(d);if(f){const m=d.index;m!==null&&f.version<m.version&&c(d)}else c(d);return a.get(d)}return{get:s,update:l,getWireframeAttribute:u}}function Oh(i,t,e,n){const r=n.isWebGL2;let a;function o(m){a=m}let s,l;function c(m){s=m.type,l=m.bytesPerElement}function u(m,v){i.drawElements(a,v,s,m*l),e.update(v,a,1)}function d(m,v,_){if(_===0)return;let p,h;if(r)p=i,h="drawElementsInstanced";else if(p=t.get("ANGLE_instanced_arrays"),h="drawElementsInstancedANGLE",p===null){console.error("THREE.WebGLIndexedBufferRenderer: using THREE.InstancedBufferGeometry but hardware does not support extension ANGLE_instanced_arrays.");return}p[h](a,v,s,m*l,_),e.update(v,a,_)}function f(m,v,_){if(_===0)return;const p=t.get("WEBGL_multi_draw");if(p===null)for(let h=0;h<_;h++)this.render(m[h]/l,v[h]);else{p.multiDrawElementsWEBGL(a,v,0,s,m,0,_);let h=0;for(let E=0;E<_;E++)h+=v[E];e.update(h,a,1)}}this.setMode=o,this.setIndex=c,this.render=u,this.renderInstances=d,this.renderMultiDraw=f}function zh(i){const t={geometries:0,textures:0},e={frame:0,calls:0,triangles:0,points:0,lines:0};function n(a,o,s){switch(e.calls++,o){case i.TRIANGLES:e.triangles+=s*(a/3);break;case i.LINES:e.lines+=s*(a/2);break;case i.LINE_STRIP:e.lines+=s*(a-1);break;case i.LINE_LOOP:e.lines+=s*a;break;case i.POINTS:e.points+=s*a;break;default:console.error("THREE.WebGLInfo: Unknown draw mode:",o);break}}function r(){e.calls=0,e.triangles=0,e.points=0,e.lines=0}return{memory:t,render:e,programs:null,autoReset:!0,reset:r,update:n}}function Bh(i,t){return i[0]-t[0]}function Vh(i,t){return Math.abs(t[1])-Math.abs(i[1])}function Hh(i,t,e){const n={},r=new Float32Array(8),a=new WeakMap,o=new ce,s=[];for(let c=0;c<8;c++)s[c]=[c,0];function l(c,u,d){const f=c.morphTargetInfluences;if(t.isWebGL2===!0){const v=u.morphAttributes.position||u.morphAttributes.normal||u.morphAttributes.color,_=v!==void 0?v.length:0;let p=a.get(u);if(p===void 0||p.count!==_){let z=function(){it.dispose(),a.delete(u),u.removeEventListener("dispose",z)};var m=z;p!==void 0&&p.texture.dispose();const T=u.morphAttributes.position!==void 0,b=u.morphAttributes.normal!==void 0,D=u.morphAttributes.color!==void 0,R=u.morphAttributes.position||[],w=u.morphAttributes.normal||[],Z=u.morphAttributes.color||[];let y=0;T===!0&&(y=1),b===!0&&(y=2),D===!0&&(y=3);let M=u.attributes.position.count*y,H=1;M>t.maxTextureSize&&(H=Math.ceil(M/t.maxTextureSize),M=t.maxTextureSize);const k=new Float32Array(M*H*4*_),it=new Ws(k,M,H,_);it.type=$e,it.needsUpdate=!0;const C=y*4;for(let V=0;V<_;V++){const X=R[V],G=w[V],W=Z[V],q=M*H*4*V;for(let Q=0;Q<X.count;Q++){const tt=Q*C;T===!0&&(o.fromBufferAttribute(X,Q),k[q+tt+0]=o.x,k[q+tt+1]=o.y,k[q+tt+2]=o.z,k[q+tt+3]=0),b===!0&&(o.fromBufferAttribute(G,Q),k[q+tt+4]=o.x,k[q+tt+5]=o.y,k[q+tt+6]=o.z,k[q+tt+7]=0),D===!0&&(o.fromBufferAttribute(W,Q),k[q+tt+8]=o.x,k[q+tt+9]=o.y,k[q+tt+10]=o.z,k[q+tt+11]=W.itemSize===4?o.w:1)}}p={count:_,texture:it,size:new Wt(M,H)},a.set(u,p),u.addEventListener("dispose",z)}let h=0;for(let T=0;T<f.length;T++)h+=f[T];const E=u.morphTargetsRelative?1:1-h;d.getUniforms().setValue(i,"morphTargetBaseInfluence",E),d.getUniforms().setValue(i,"morphTargetInfluences",f),d.getUniforms().setValue(i,"morphTargetsTexture",p.texture,e),d.getUniforms().setValue(i,"morphTargetsTextureSize",p.size)}else{const v=f===void 0?0:f.length;let _=n[u.id];if(_===void 0||_.length!==v){_=[];for(let b=0;b<v;b++)_[b]=[b,0];n[u.id]=_}for(let b=0;b<v;b++){const D=_[b];D[0]=b,D[1]=f[b]}_.sort(Vh);for(let b=0;b<8;b++)b<v&&_[b][1]?(s[b][0]=_[b][0],s[b][1]=_[b][1]):(s[b][0]=Number.MAX_SAFE_INTEGER,s[b][1]=0);s.sort(Bh);const p=u.morphAttributes.position,h=u.morphAttributes.normal;let E=0;for(let b=0;b<8;b++){const D=s[b],R=D[0],w=D[1];R!==Number.MAX_SAFE_INTEGER&&w?(p&&u.getAttribute("morphTarget"+b)!==p[R]&&u.setAttribute("morphTarget"+b,p[R]),h&&u.getAttribute("morphNormal"+b)!==h[R]&&u.setAttribute("morphNormal"+b,h[R]),r[b]=w,E+=w):(p&&u.hasAttribute("morphTarget"+b)===!0&&u.deleteAttribute("morphTarget"+b),h&&u.hasAttribute("morphNormal"+b)===!0&&u.deleteAttribute("morphNormal"+b),r[b]=0)}const T=u.morphTargetsRelative?1:1-E;d.getUniforms().setValue(i,"morphTargetBaseInfluence",T),d.getUniforms().setValue(i,"morphTargetInfluences",r)}}return{update:l}}function Gh(i,t,e,n){let r=new WeakMap;function a(l){const c=n.render.frame,u=l.geometry,d=t.get(l,u);if(r.get(d)!==c&&(t.update(d),r.set(d,c)),l.isInstancedMesh&&(l.hasEventListener("dispose",s)===!1&&l.addEventListener("dispose",s),r.get(l)!==c&&(e.update(l.instanceMatrix,i.ARRAY_BUFFER),l.instanceColor!==null&&e.update(l.instanceColor,i.ARRAY_BUFFER),r.set(l,c))),l.isSkinnedMesh){const f=l.skeleton;r.get(f)!==c&&(f.update(),r.set(f,c))}return d}function o(){r=new WeakMap}function s(l){const c=l.target;c.removeEventListener("dispose",s),e.remove(c.instanceMatrix),c.instanceColor!==null&&e.remove(c.instanceColor)}return{update:a,dispose:o}}class no extends Se{constructor(t,e,n,r,a,o,s,l,c,u){if(u=u!==void 0?u:En,u!==En&&u!==$n)throw new Error("DepthTexture format must be either THREE.DepthFormat or THREE.DepthStencilFormat");n===void 0&&u===En&&(n=sn),n===void 0&&u===$n&&(n=Mn),super(null,r,a,o,s,l,u,n,c),this.isDepthTexture=!0,this.image={width:t,height:e},this.magFilter=s!==void 0?s:oe,this.minFilter=l!==void 0?l:oe,this.flipY=!1,this.generateMipmaps=!1,this.compareFunction=null}copy(t){return super.copy(t),this.compareFunction=t.compareFunction,this}toJSON(t){const e=super.toJSON(t);return this.compareFunction!==null&&(e.compareFunction=this.compareFunction),e}}const io=new Se,ro=new no(1,1);ro.compareFunction=Vs;const ao=new Ws,so=new bl,oo=new Js,hs=[],ds=[],fs=new Float32Array(16),ps=new Float32Array(9),ms=new Float32Array(4);function Kn(i,t,e){const n=i[0];if(n<=0||n>0)return i;const r=t*e;let a=hs[r];if(a===void 0&&(a=new Float32Array(r),hs[r]=a),t!==0){n.toArray(a,0);for(let o=1,s=0;o!==t;++o)s+=e,i[o].toArray(a,s)}return a}function ne(i,t){if(i.length!==t.length)return!1;for(let e=0,n=i.length;e<n;e++)if(i[e]!==t[e])return!1;return!0}function ie(i,t){for(let e=0,n=t.length;e<n;e++)i[e]=t[e]}function Zi(i,t){let e=ds[t];e===void 0&&(e=new Int32Array(t),ds[t]=e);for(let n=0;n!==t;++n)e[n]=i.allocateTextureUnit();return e}function kh(i,t){const e=this.cache;e[0]!==t&&(i.uniform1f(this.addr,t),e[0]=t)}function Wh(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y)&&(i.uniform2f(this.addr,t.x,t.y),e[0]=t.x,e[1]=t.y);else{if(ne(e,t))return;i.uniform2fv(this.addr,t),ie(e,t)}}function Xh(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z)&&(i.uniform3f(this.addr,t.x,t.y,t.z),e[0]=t.x,e[1]=t.y,e[2]=t.z);else if(t.r!==void 0)(e[0]!==t.r||e[1]!==t.g||e[2]!==t.b)&&(i.uniform3f(this.addr,t.r,t.g,t.b),e[0]=t.r,e[1]=t.g,e[2]=t.b);else{if(ne(e,t))return;i.uniform3fv(this.addr,t),ie(e,t)}}function qh(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z||e[3]!==t.w)&&(i.uniform4f(this.addr,t.x,t.y,t.z,t.w),e[0]=t.x,e[1]=t.y,e[2]=t.z,e[3]=t.w);else{if(ne(e,t))return;i.uniform4fv(this.addr,t),ie(e,t)}}function Yh(i,t){const e=this.cache,n=t.elements;if(n===void 0){if(ne(e,t))return;i.uniformMatrix2fv(this.addr,!1,t),ie(e,t)}else{if(ne(e,n))return;ms.set(n),i.uniformMatrix2fv(this.addr,!1,ms),ie(e,n)}}function $h(i,t){const e=this.cache,n=t.elements;if(n===void 0){if(ne(e,t))return;i.uniformMatrix3fv(this.addr,!1,t),ie(e,t)}else{if(ne(e,n))return;ps.set(n),i.uniformMatrix3fv(this.addr,!1,ps),ie(e,n)}}function jh(i,t){const e=this.cache,n=t.elements;if(n===void 0){if(ne(e,t))return;i.uniformMatrix4fv(this.addr,!1,t),ie(e,t)}else{if(ne(e,n))return;fs.set(n),i.uniformMatrix4fv(this.addr,!1,fs),ie(e,n)}}function Zh(i,t){const e=this.cache;e[0]!==t&&(i.uniform1i(this.addr,t),e[0]=t)}function Kh(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y)&&(i.uniform2i(this.addr,t.x,t.y),e[0]=t.x,e[1]=t.y);else{if(ne(e,t))return;i.uniform2iv(this.addr,t),ie(e,t)}}function Jh(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z)&&(i.uniform3i(this.addr,t.x,t.y,t.z),e[0]=t.x,e[1]=t.y,e[2]=t.z);else{if(ne(e,t))return;i.uniform3iv(this.addr,t),ie(e,t)}}function Qh(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z||e[3]!==t.w)&&(i.uniform4i(this.addr,t.x,t.y,t.z,t.w),e[0]=t.x,e[1]=t.y,e[2]=t.z,e[3]=t.w);else{if(ne(e,t))return;i.uniform4iv(this.addr,t),ie(e,t)}}function td(i,t){const e=this.cache;e[0]!==t&&(i.uniform1ui(this.addr,t),e[0]=t)}function ed(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y)&&(i.uniform2ui(this.addr,t.x,t.y),e[0]=t.x,e[1]=t.y);else{if(ne(e,t))return;i.uniform2uiv(this.addr,t),ie(e,t)}}function nd(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z)&&(i.uniform3ui(this.addr,t.x,t.y,t.z),e[0]=t.x,e[1]=t.y,e[2]=t.z);else{if(ne(e,t))return;i.uniform3uiv(this.addr,t),ie(e,t)}}function id(i,t){const e=this.cache;if(t.x!==void 0)(e[0]!==t.x||e[1]!==t.y||e[2]!==t.z||e[3]!==t.w)&&(i.uniform4ui(this.addr,t.x,t.y,t.z,t.w),e[0]=t.x,e[1]=t.y,e[2]=t.z,e[3]=t.w);else{if(ne(e,t))return;i.uniform4uiv(this.addr,t),ie(e,t)}}function rd(i,t,e){const n=this.cache,r=e.allocateTextureUnit();n[0]!==r&&(i.uniform1i(this.addr,r),n[0]=r);const a=this.type===i.SAMPLER_2D_SHADOW?ro:io;e.setTexture2D(t||a,r)}function ad(i,t,e){const n=this.cache,r=e.allocateTextureUnit();n[0]!==r&&(i.uniform1i(this.addr,r),n[0]=r),e.setTexture3D(t||so,r)}function sd(i,t,e){const n=this.cache,r=e.allocateTextureUnit();n[0]!==r&&(i.uniform1i(this.addr,r),n[0]=r),e.setTextureCube(t||oo,r)}function od(i,t,e){const n=this.cache,r=e.allocateTextureUnit();n[0]!==r&&(i.uniform1i(this.addr,r),n[0]=r),e.setTexture2DArray(t||ao,r)}function ld(i){switch(i){case 5126:return kh;case 35664:return Wh;case 35665:return Xh;case 35666:return qh;case 35674:return Yh;case 35675:return $h;case 35676:return jh;case 5124:case 35670:return Zh;case 35667:case 35671:return Kh;case 35668:case 35672:return Jh;case 35669:case 35673:return Qh;case 5125:return td;case 36294:return ed;case 36295:return nd;case 36296:return id;case 35678:case 36198:case 36298:case 36306:case 35682:return rd;case 35679:case 36299:case 36307:return ad;case 35680:case 36300:case 36308:case 36293:return sd;case 36289:case 36303:case 36311:case 36292:return od}}function cd(i,t){i.uniform1fv(this.addr,t)}function ud(i,t){const e=Kn(t,this.size,2);i.uniform2fv(this.addr,e)}function hd(i,t){const e=Kn(t,this.size,3);i.uniform3fv(this.addr,e)}function dd(i,t){const e=Kn(t,this.size,4);i.uniform4fv(this.addr,e)}function fd(i,t){const e=Kn(t,this.size,4);i.uniformMatrix2fv(this.addr,!1,e)}function pd(i,t){const e=Kn(t,this.size,9);i.uniformMatrix3fv(this.addr,!1,e)}function md(i,t){const e=Kn(t,this.size,16);i.uniformMatrix4fv(this.addr,!1,e)}function gd(i,t){i.uniform1iv(this.addr,t)}function _d(i,t){i.uniform2iv(this.addr,t)}function vd(i,t){i.uniform3iv(this.addr,t)}function xd(i,t){i.uniform4iv(this.addr,t)}function Sd(i,t){i.uniform1uiv(this.addr,t)}function yd(i,t){i.uniform2uiv(this.addr,t)}function Td(i,t){i.uniform3uiv(this.addr,t)}function Md(i,t){i.uniform4uiv(this.addr,t)}function Ed(i,t,e){const n=this.cache,r=t.length,a=Zi(e,r);ne(n,a)||(i.uniform1iv(this.addr,a),ie(n,a));for(let o=0;o!==r;++o)e.setTexture2D(t[o]||io,a[o])}function bd(i,t,e){const n=this.cache,r=t.length,a=Zi(e,r);ne(n,a)||(i.uniform1iv(this.addr,a),ie(n,a));for(let o=0;o!==r;++o)e.setTexture3D(t[o]||so,a[o])}function Ad(i,t,e){const n=this.cache,r=t.length,a=Zi(e,r);ne(n,a)||(i.uniform1iv(this.addr,a),ie(n,a));for(let o=0;o!==r;++o)e.setTextureCube(t[o]||oo,a[o])}function wd(i,t,e){const n=this.cache,r=t.length,a=Zi(e,r);ne(n,a)||(i.uniform1iv(this.addr,a),ie(n,a));for(let o=0;o!==r;++o)e.setTexture2DArray(t[o]||ao,a[o])}function Rd(i){switch(i){case 5126:return cd;case 35664:return ud;case 35665:return hd;case 35666:return dd;case 35674:return fd;case 35675:return pd;case 35676:return md;case 5124:case 35670:return gd;case 35667:case 35671:return _d;case 35668:case 35672:return vd;case 35669:case 35673:return xd;case 5125:return Sd;case 36294:return yd;case 36295:return Td;case 36296:return Md;case 35678:case 36198:case 36298:case 36306:case 35682:return Ed;case 35679:case 36299:case 36307:return bd;case 35680:case 36300:case 36308:case 36293:return Ad;case 36289:case 36303:case 36311:case 36292:return wd}}class Cd{constructor(t,e,n){this.id=t,this.addr=n,this.cache=[],this.type=e.type,this.setValue=ld(e.type)}}class Pd{constructor(t,e,n){this.id=t,this.addr=n,this.cache=[],this.type=e.type,this.size=e.size,this.setValue=Rd(e.type)}}class Ld{constructor(t){this.id=t,this.seq=[],this.map={}}setValue(t,e,n){const r=this.seq;for(let a=0,o=r.length;a!==o;++a){const s=r[a];s.setValue(t,e[s.id],n)}}}const Pr=/(\w+)(\])?(\[|\.)?/g;function gs(i,t){i.seq.push(t),i.map[t.id]=t}function Dd(i,t,e){const n=i.name,r=n.length;for(Pr.lastIndex=0;;){const a=Pr.exec(n),o=Pr.lastIndex;let s=a[1];const l=a[2]==="]",c=a[3];if(l&&(s=s|0),c===void 0||c==="["&&o+2===r){gs(e,c===void 0?new Cd(s,i,t):new Pd(s,i,t));break}else{let d=e.map[s];d===void 0&&(d=new Ld(s),gs(e,d)),e=d}}}class Bi{constructor(t,e){this.seq=[],this.map={};const n=t.getProgramParameter(e,t.ACTIVE_UNIFORMS);for(let r=0;r<n;++r){const a=t.getActiveUniform(e,r),o=t.getUniformLocation(e,a.name);Dd(a,o,this)}}setValue(t,e,n,r){const a=this.map[e];a!==void 0&&a.setValue(t,n,r)}setOptional(t,e,n){const r=e[n];r!==void 0&&this.setValue(t,n,r)}static upload(t,e,n,r){for(let a=0,o=e.length;a!==o;++a){const s=e[a],l=n[s.id];l.needsUpdate!==!1&&s.setValue(t,l.value,r)}}static seqWithValue(t,e){const n=[];for(let r=0,a=t.length;r!==a;++r){const o=t[r];o.id in e&&n.push(o)}return n}}function _s(i,t,e){const n=i.createShader(t);return i.shaderSource(n,e),i.compileShader(n),n}const Ud=37297;let Id=0;function Nd(i,t){const e=i.split(`
`),n=[],r=Math.max(t-6,0),a=Math.min(t+6,e.length);for(let o=r;o<a;o++){const s=o+1;n.push(`${s===t?">":" "} ${s}: ${e[o]}`)}return n.join(`
`)}function Fd(i){const t=Gt.getPrimaries(Gt.workingColorSpace),e=Gt.getPrimaries(i);let n;switch(t===e?n="":t===ki&&e===Gi?n="LinearDisplayP3ToLinearSRGB":t===Gi&&e===ki&&(n="LinearSRGBToLinearDisplayP3"),i){case Je:case Yi:return[n,"LinearTransferOETF"];case le:case Yr:return[n,"sRGBTransferOETF"];default:return console.warn("THREE.WebGLProgram: Unsupported color space:",i),[n,"LinearTransferOETF"]}}function vs(i,t,e){const n=i.getShaderParameter(t,i.COMPILE_STATUS),r=i.getShaderInfoLog(t).trim();if(n&&r==="")return"";const a=/ERROR: 0:(\d+)/.exec(r);if(a){const o=parseInt(a[1]);return e.toUpperCase()+`

`+r+`

`+Nd(i.getShaderSource(t),o)}else return r}function Od(i,t){const e=Fd(t);return`vec4 ${i}( vec4 value ) { return ${e[0]}( ${e[1]}( value ) ); }`}function zd(i,t){let e;switch(t){case Yo:e="Linear";break;case $o:e="Reinhard";break;case jo:e="OptimizedCineon";break;case Zo:e="ACESFilmic";break;case Jo:e="AgX";break;case Ko:e="Custom";break;default:console.warn("THREE.WebGLProgram: Unsupported toneMapping:",t),e="Linear"}return"vec3 "+i+"( vec3 color ) { return "+e+"ToneMapping( color ); }"}function Bd(i){return[i.extensionDerivatives||i.envMapCubeUVHeight||i.bumpMap||i.normalMapTangentSpace||i.clearcoatNormalMap||i.flatShading||i.shaderID==="physical"?"#extension GL_OES_standard_derivatives : enable":"",(i.extensionFragDepth||i.logarithmicDepthBuffer)&&i.rendererExtensionFragDepth?"#extension GL_EXT_frag_depth : enable":"",i.extensionDrawBuffers&&i.rendererExtensionDrawBuffers?"#extension GL_EXT_draw_buffers : require":"",(i.extensionShaderTextureLOD||i.envMap||i.transmission)&&i.rendererExtensionShaderTextureLod?"#extension GL_EXT_shader_texture_lod : enable":""].filter(kn).join(`
`)}function Vd(i){return[i.extensionClipCullDistance?"#extension GL_ANGLE_clip_cull_distance : require":""].filter(kn).join(`
`)}function Hd(i){const t=[];for(const e in i){const n=i[e];n!==!1&&t.push("#define "+e+" "+n)}return t.join(`
`)}function Gd(i,t){const e={},n=i.getProgramParameter(t,i.ACTIVE_ATTRIBUTES);for(let r=0;r<n;r++){const a=i.getActiveAttrib(t,r),o=a.name;let s=1;a.type===i.FLOAT_MAT2&&(s=2),a.type===i.FLOAT_MAT3&&(s=3),a.type===i.FLOAT_MAT4&&(s=4),e[o]={type:a.type,location:i.getAttribLocation(t,o),locationSize:s}}return e}function kn(i){return i!==""}function xs(i,t){const e=t.numSpotLightShadows+t.numSpotLightMaps-t.numSpotLightShadowsWithMaps;return i.replace(/NUM_DIR_LIGHTS/g,t.numDirLights).replace(/NUM_SPOT_LIGHTS/g,t.numSpotLights).replace(/NUM_SPOT_LIGHT_MAPS/g,t.numSpotLightMaps).replace(/NUM_SPOT_LIGHT_COORDS/g,e).replace(/NUM_RECT_AREA_LIGHTS/g,t.numRectAreaLights).replace(/NUM_POINT_LIGHTS/g,t.numPointLights).replace(/NUM_HEMI_LIGHTS/g,t.numHemiLights).replace(/NUM_DIR_LIGHT_SHADOWS/g,t.numDirLightShadows).replace(/NUM_SPOT_LIGHT_SHADOWS_WITH_MAPS/g,t.numSpotLightShadowsWithMaps).replace(/NUM_SPOT_LIGHT_SHADOWS/g,t.numSpotLightShadows).replace(/NUM_POINT_LIGHT_SHADOWS/g,t.numPointLightShadows)}function Ss(i,t){return i.replace(/NUM_CLIPPING_PLANES/g,t.numClippingPlanes).replace(/UNION_CLIPPING_PLANES/g,t.numClippingPlanes-t.numClipIntersection)}const kd=/^[ \t]*#include +<([\w\d./]+)>/gm;function kr(i){return i.replace(kd,Xd)}const Wd=new Map([["encodings_fragment","colorspace_fragment"],["encodings_pars_fragment","colorspace_pars_fragment"],["output_fragment","opaque_fragment"]]);function Xd(i,t){let e=Dt[t];if(e===void 0){const n=Wd.get(t);if(n!==void 0)e=Dt[n],console.warn('THREE.WebGLRenderer: Shader chunk "%s" has been deprecated. Use "%s" instead.',t,n);else throw new Error("Can not resolve #include <"+t+">")}return kr(e)}const qd=/#pragma unroll_loop_start\s+for\s*\(\s*int\s+i\s*=\s*(\d+)\s*;\s*i\s*<\s*(\d+)\s*;\s*i\s*\+\+\s*\)\s*{([\s\S]+?)}\s+#pragma unroll_loop_end/g;function ys(i){return i.replace(qd,Yd)}function Yd(i,t,e,n){let r="";for(let a=parseInt(t);a<parseInt(e);a++)r+=n.replace(/\[\s*i\s*\]/g,"[ "+a+" ]").replace(/UNROLLED_LOOP_INDEX/g,a);return r}function Ts(i){let t="precision "+i.precision+` float;
precision `+i.precision+" int;";return i.precision==="highp"?t+=`
#define HIGH_PRECISION`:i.precision==="mediump"?t+=`
#define MEDIUM_PRECISION`:i.precision==="lowp"&&(t+=`
#define LOW_PRECISION`),t}function $d(i){let t="SHADOWMAP_TYPE_BASIC";return i.shadowMapType===Cs?t="SHADOWMAP_TYPE_PCF":i.shadowMapType===yo?t="SHADOWMAP_TYPE_PCF_SOFT":i.shadowMapType===qe&&(t="SHADOWMAP_TYPE_VSM"),t}function jd(i){let t="ENVMAP_TYPE_CUBE";if(i.envMap)switch(i.envMapMode){case qn:case Yn:t="ENVMAP_TYPE_CUBE";break;case qi:t="ENVMAP_TYPE_CUBE_UV";break}return t}function Zd(i){let t="ENVMAP_MODE_REFLECTION";if(i.envMap)switch(i.envMapMode){case Yn:t="ENVMAP_MODE_REFRACTION";break}return t}function Kd(i){let t="ENVMAP_BLENDING_NONE";if(i.envMap)switch(i.combine){case Ps:t="ENVMAP_BLENDING_MULTIPLY";break;case Xo:t="ENVMAP_BLENDING_MIX";break;case qo:t="ENVMAP_BLENDING_ADD";break}return t}function Jd(i){const t=i.envMapCubeUVHeight;if(t===null)return null;const e=Math.log2(t)-2,n=1/t;return{texelWidth:1/(3*Math.max(Math.pow(2,e),7*16)),texelHeight:n,maxMip:e}}function Qd(i,t,e,n){const r=i.getContext(),a=e.defines;let o=e.vertexShader,s=e.fragmentShader;const l=$d(e),c=jd(e),u=Zd(e),d=Kd(e),f=Jd(e),m=e.isWebGL2?"":Bd(e),v=Vd(e),_=Hd(a),p=r.createProgram();let h,E,T=e.glslVersion?"#version "+e.glslVersion+`
`:"";e.isRawShaderMaterial?(h=["#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,_].filter(kn).join(`
`),h.length>0&&(h+=`
`),E=[m,"#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,_].filter(kn).join(`
`),E.length>0&&(E+=`
`)):(h=[Ts(e),"#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,_,e.extensionClipCullDistance?"#define USE_CLIP_DISTANCE":"",e.batching?"#define USE_BATCHING":"",e.instancing?"#define USE_INSTANCING":"",e.instancingColor?"#define USE_INSTANCING_COLOR":"",e.useFog&&e.fog?"#define USE_FOG":"",e.useFog&&e.fogExp2?"#define FOG_EXP2":"",e.map?"#define USE_MAP":"",e.envMap?"#define USE_ENVMAP":"",e.envMap?"#define "+u:"",e.lightMap?"#define USE_LIGHTMAP":"",e.aoMap?"#define USE_AOMAP":"",e.bumpMap?"#define USE_BUMPMAP":"",e.normalMap?"#define USE_NORMALMAP":"",e.normalMapObjectSpace?"#define USE_NORMALMAP_OBJECTSPACE":"",e.normalMapTangentSpace?"#define USE_NORMALMAP_TANGENTSPACE":"",e.displacementMap?"#define USE_DISPLACEMENTMAP":"",e.emissiveMap?"#define USE_EMISSIVEMAP":"",e.anisotropy?"#define USE_ANISOTROPY":"",e.anisotropyMap?"#define USE_ANISOTROPYMAP":"",e.clearcoatMap?"#define USE_CLEARCOATMAP":"",e.clearcoatRoughnessMap?"#define USE_CLEARCOAT_ROUGHNESSMAP":"",e.clearcoatNormalMap?"#define USE_CLEARCOAT_NORMALMAP":"",e.iridescenceMap?"#define USE_IRIDESCENCEMAP":"",e.iridescenceThicknessMap?"#define USE_IRIDESCENCE_THICKNESSMAP":"",e.specularMap?"#define USE_SPECULARMAP":"",e.specularColorMap?"#define USE_SPECULAR_COLORMAP":"",e.specularIntensityMap?"#define USE_SPECULAR_INTENSITYMAP":"",e.roughnessMap?"#define USE_ROUGHNESSMAP":"",e.metalnessMap?"#define USE_METALNESSMAP":"",e.alphaMap?"#define USE_ALPHAMAP":"",e.alphaHash?"#define USE_ALPHAHASH":"",e.transmission?"#define USE_TRANSMISSION":"",e.transmissionMap?"#define USE_TRANSMISSIONMAP":"",e.thicknessMap?"#define USE_THICKNESSMAP":"",e.sheenColorMap?"#define USE_SHEEN_COLORMAP":"",e.sheenRoughnessMap?"#define USE_SHEEN_ROUGHNESSMAP":"",e.mapUv?"#define MAP_UV "+e.mapUv:"",e.alphaMapUv?"#define ALPHAMAP_UV "+e.alphaMapUv:"",e.lightMapUv?"#define LIGHTMAP_UV "+e.lightMapUv:"",e.aoMapUv?"#define AOMAP_UV "+e.aoMapUv:"",e.emissiveMapUv?"#define EMISSIVEMAP_UV "+e.emissiveMapUv:"",e.bumpMapUv?"#define BUMPMAP_UV "+e.bumpMapUv:"",e.normalMapUv?"#define NORMALMAP_UV "+e.normalMapUv:"",e.displacementMapUv?"#define DISPLACEMENTMAP_UV "+e.displacementMapUv:"",e.metalnessMapUv?"#define METALNESSMAP_UV "+e.metalnessMapUv:"",e.roughnessMapUv?"#define ROUGHNESSMAP_UV "+e.roughnessMapUv:"",e.anisotropyMapUv?"#define ANISOTROPYMAP_UV "+e.anisotropyMapUv:"",e.clearcoatMapUv?"#define CLEARCOATMAP_UV "+e.clearcoatMapUv:"",e.clearcoatNormalMapUv?"#define CLEARCOAT_NORMALMAP_UV "+e.clearcoatNormalMapUv:"",e.clearcoatRoughnessMapUv?"#define CLEARCOAT_ROUGHNESSMAP_UV "+e.clearcoatRoughnessMapUv:"",e.iridescenceMapUv?"#define IRIDESCENCEMAP_UV "+e.iridescenceMapUv:"",e.iridescenceThicknessMapUv?"#define IRIDESCENCE_THICKNESSMAP_UV "+e.iridescenceThicknessMapUv:"",e.sheenColorMapUv?"#define SHEEN_COLORMAP_UV "+e.sheenColorMapUv:"",e.sheenRoughnessMapUv?"#define SHEEN_ROUGHNESSMAP_UV "+e.sheenRoughnessMapUv:"",e.specularMapUv?"#define SPECULARMAP_UV "+e.specularMapUv:"",e.specularColorMapUv?"#define SPECULAR_COLORMAP_UV "+e.specularColorMapUv:"",e.specularIntensityMapUv?"#define SPECULAR_INTENSITYMAP_UV "+e.specularIntensityMapUv:"",e.transmissionMapUv?"#define TRANSMISSIONMAP_UV "+e.transmissionMapUv:"",e.thicknessMapUv?"#define THICKNESSMAP_UV "+e.thicknessMapUv:"",e.vertexTangents&&e.flatShading===!1?"#define USE_TANGENT":"",e.vertexColors?"#define USE_COLOR":"",e.vertexAlphas?"#define USE_COLOR_ALPHA":"",e.vertexUv1s?"#define USE_UV1":"",e.vertexUv2s?"#define USE_UV2":"",e.vertexUv3s?"#define USE_UV3":"",e.pointsUvs?"#define USE_POINTS_UV":"",e.flatShading?"#define FLAT_SHADED":"",e.skinning?"#define USE_SKINNING":"",e.morphTargets?"#define USE_MORPHTARGETS":"",e.morphNormals&&e.flatShading===!1?"#define USE_MORPHNORMALS":"",e.morphColors&&e.isWebGL2?"#define USE_MORPHCOLORS":"",e.morphTargetsCount>0&&e.isWebGL2?"#define MORPHTARGETS_TEXTURE":"",e.morphTargetsCount>0&&e.isWebGL2?"#define MORPHTARGETS_TEXTURE_STRIDE "+e.morphTextureStride:"",e.morphTargetsCount>0&&e.isWebGL2?"#define MORPHTARGETS_COUNT "+e.morphTargetsCount:"",e.doubleSided?"#define DOUBLE_SIDED":"",e.flipSided?"#define FLIP_SIDED":"",e.shadowMapEnabled?"#define USE_SHADOWMAP":"",e.shadowMapEnabled?"#define "+l:"",e.sizeAttenuation?"#define USE_SIZEATTENUATION":"",e.numLightProbes>0?"#define USE_LIGHT_PROBES":"",e.useLegacyLights?"#define LEGACY_LIGHTS":"",e.logarithmicDepthBuffer?"#define USE_LOGDEPTHBUF":"",e.logarithmicDepthBuffer&&e.rendererExtensionFragDepth?"#define USE_LOGDEPTHBUF_EXT":"","uniform mat4 modelMatrix;","uniform mat4 modelViewMatrix;","uniform mat4 projectionMatrix;","uniform mat4 viewMatrix;","uniform mat3 normalMatrix;","uniform vec3 cameraPosition;","uniform bool isOrthographic;","#ifdef USE_INSTANCING","	attribute mat4 instanceMatrix;","#endif","#ifdef USE_INSTANCING_COLOR","	attribute vec3 instanceColor;","#endif","attribute vec3 position;","attribute vec3 normal;","attribute vec2 uv;","#ifdef USE_UV1","	attribute vec2 uv1;","#endif","#ifdef USE_UV2","	attribute vec2 uv2;","#endif","#ifdef USE_UV3","	attribute vec2 uv3;","#endif","#ifdef USE_TANGENT","	attribute vec4 tangent;","#endif","#if defined( USE_COLOR_ALPHA )","	attribute vec4 color;","#elif defined( USE_COLOR )","	attribute vec3 color;","#endif","#if ( defined( USE_MORPHTARGETS ) && ! defined( MORPHTARGETS_TEXTURE ) )","	attribute vec3 morphTarget0;","	attribute vec3 morphTarget1;","	attribute vec3 morphTarget2;","	attribute vec3 morphTarget3;","	#ifdef USE_MORPHNORMALS","		attribute vec3 morphNormal0;","		attribute vec3 morphNormal1;","		attribute vec3 morphNormal2;","		attribute vec3 morphNormal3;","	#else","		attribute vec3 morphTarget4;","		attribute vec3 morphTarget5;","		attribute vec3 morphTarget6;","		attribute vec3 morphTarget7;","	#endif","#endif","#ifdef USE_SKINNING","	attribute vec4 skinIndex;","	attribute vec4 skinWeight;","#endif",`
`].filter(kn).join(`
`),E=[m,Ts(e),"#define SHADER_TYPE "+e.shaderType,"#define SHADER_NAME "+e.shaderName,_,e.useFog&&e.fog?"#define USE_FOG":"",e.useFog&&e.fogExp2?"#define FOG_EXP2":"",e.map?"#define USE_MAP":"",e.matcap?"#define USE_MATCAP":"",e.envMap?"#define USE_ENVMAP":"",e.envMap?"#define "+c:"",e.envMap?"#define "+u:"",e.envMap?"#define "+d:"",f?"#define CUBEUV_TEXEL_WIDTH "+f.texelWidth:"",f?"#define CUBEUV_TEXEL_HEIGHT "+f.texelHeight:"",f?"#define CUBEUV_MAX_MIP "+f.maxMip+".0":"",e.lightMap?"#define USE_LIGHTMAP":"",e.aoMap?"#define USE_AOMAP":"",e.bumpMap?"#define USE_BUMPMAP":"",e.normalMap?"#define USE_NORMALMAP":"",e.normalMapObjectSpace?"#define USE_NORMALMAP_OBJECTSPACE":"",e.normalMapTangentSpace?"#define USE_NORMALMAP_TANGENTSPACE":"",e.emissiveMap?"#define USE_EMISSIVEMAP":"",e.anisotropy?"#define USE_ANISOTROPY":"",e.anisotropyMap?"#define USE_ANISOTROPYMAP":"",e.clearcoat?"#define USE_CLEARCOAT":"",e.clearcoatMap?"#define USE_CLEARCOATMAP":"",e.clearcoatRoughnessMap?"#define USE_CLEARCOAT_ROUGHNESSMAP":"",e.clearcoatNormalMap?"#define USE_CLEARCOAT_NORMALMAP":"",e.iridescence?"#define USE_IRIDESCENCE":"",e.iridescenceMap?"#define USE_IRIDESCENCEMAP":"",e.iridescenceThicknessMap?"#define USE_IRIDESCENCE_THICKNESSMAP":"",e.specularMap?"#define USE_SPECULARMAP":"",e.specularColorMap?"#define USE_SPECULAR_COLORMAP":"",e.specularIntensityMap?"#define USE_SPECULAR_INTENSITYMAP":"",e.roughnessMap?"#define USE_ROUGHNESSMAP":"",e.metalnessMap?"#define USE_METALNESSMAP":"",e.alphaMap?"#define USE_ALPHAMAP":"",e.alphaTest?"#define USE_ALPHATEST":"",e.alphaHash?"#define USE_ALPHAHASH":"",e.sheen?"#define USE_SHEEN":"",e.sheenColorMap?"#define USE_SHEEN_COLORMAP":"",e.sheenRoughnessMap?"#define USE_SHEEN_ROUGHNESSMAP":"",e.transmission?"#define USE_TRANSMISSION":"",e.transmissionMap?"#define USE_TRANSMISSIONMAP":"",e.thicknessMap?"#define USE_THICKNESSMAP":"",e.vertexTangents&&e.flatShading===!1?"#define USE_TANGENT":"",e.vertexColors||e.instancingColor?"#define USE_COLOR":"",e.vertexAlphas?"#define USE_COLOR_ALPHA":"",e.vertexUv1s?"#define USE_UV1":"",e.vertexUv2s?"#define USE_UV2":"",e.vertexUv3s?"#define USE_UV3":"",e.pointsUvs?"#define USE_POINTS_UV":"",e.gradientMap?"#define USE_GRADIENTMAP":"",e.flatShading?"#define FLAT_SHADED":"",e.doubleSided?"#define DOUBLE_SIDED":"",e.flipSided?"#define FLIP_SIDED":"",e.shadowMapEnabled?"#define USE_SHADOWMAP":"",e.shadowMapEnabled?"#define "+l:"",e.premultipliedAlpha?"#define PREMULTIPLIED_ALPHA":"",e.numLightProbes>0?"#define USE_LIGHT_PROBES":"",e.useLegacyLights?"#define LEGACY_LIGHTS":"",e.decodeVideoTexture?"#define DECODE_VIDEO_TEXTURE":"",e.logarithmicDepthBuffer?"#define USE_LOGDEPTHBUF":"",e.logarithmicDepthBuffer&&e.rendererExtensionFragDepth?"#define USE_LOGDEPTHBUF_EXT":"","uniform mat4 viewMatrix;","uniform vec3 cameraPosition;","uniform bool isOrthographic;",e.toneMapping!==ln?"#define TONE_MAPPING":"",e.toneMapping!==ln?Dt.tonemapping_pars_fragment:"",e.toneMapping!==ln?zd("toneMapping",e.toneMapping):"",e.dithering?"#define DITHERING":"",e.opaque?"#define OPAQUE":"",Dt.colorspace_pars_fragment,Od("linearToOutputTexel",e.outputColorSpace),e.useDepthPacking?"#define DEPTH_PACKING "+e.depthPacking:"",`
`].filter(kn).join(`
`)),o=kr(o),o=xs(o,e),o=Ss(o,e),s=kr(s),s=xs(s,e),s=Ss(s,e),o=ys(o),s=ys(s),e.isWebGL2&&e.isRawShaderMaterial!==!0&&(T=`#version 300 es
`,h=[v,"precision mediump sampler2DArray;","#define attribute in","#define varying out","#define texture2D texture"].join(`
`)+`
`+h,E=["precision mediump sampler2DArray;","#define varying in",e.glslVersion===Va?"":"layout(location = 0) out highp vec4 pc_fragColor;",e.glslVersion===Va?"":"#define gl_FragColor pc_fragColor","#define gl_FragDepthEXT gl_FragDepth","#define texture2D texture","#define textureCube texture","#define texture2DProj textureProj","#define texture2DLodEXT textureLod","#define texture2DProjLodEXT textureProjLod","#define textureCubeLodEXT textureLod","#define texture2DGradEXT textureGrad","#define texture2DProjGradEXT textureProjGrad","#define textureCubeGradEXT textureGrad"].join(`
`)+`
`+E);const b=T+h+o,D=T+E+s,R=_s(r,r.VERTEX_SHADER,b),w=_s(r,r.FRAGMENT_SHADER,D);r.attachShader(p,R),r.attachShader(p,w),e.index0AttributeName!==void 0?r.bindAttribLocation(p,0,e.index0AttributeName):e.morphTargets===!0&&r.bindAttribLocation(p,0,"position"),r.linkProgram(p);function Z(k){if(i.debug.checkShaderErrors){const it=r.getProgramInfoLog(p).trim(),C=r.getShaderInfoLog(R).trim(),z=r.getShaderInfoLog(w).trim();let V=!0,X=!0;if(r.getProgramParameter(p,r.LINK_STATUS)===!1)if(V=!1,typeof i.debug.onShaderError=="function")i.debug.onShaderError(r,p,R,w);else{const G=vs(r,R,"vertex"),W=vs(r,w,"fragment");console.error("THREE.WebGLProgram: Shader Error "+r.getError()+" - VALIDATE_STATUS "+r.getProgramParameter(p,r.VALIDATE_STATUS)+`

Program Info Log: `+it+`
`+G+`
`+W)}else it!==""?console.warn("THREE.WebGLProgram: Program Info Log:",it):(C===""||z==="")&&(X=!1);X&&(k.diagnostics={runnable:V,programLog:it,vertexShader:{log:C,prefix:h},fragmentShader:{log:z,prefix:E}})}r.deleteShader(R),r.deleteShader(w),y=new Bi(r,p),M=Gd(r,p)}let y;this.getUniforms=function(){return y===void 0&&Z(this),y};let M;this.getAttributes=function(){return M===void 0&&Z(this),M};let H=e.rendererExtensionParallelShaderCompile===!1;return this.isReady=function(){return H===!1&&(H=r.getProgramParameter(p,Ud)),H},this.destroy=function(){n.releaseStatesOfProgram(this),r.deleteProgram(p),this.program=void 0},this.type=e.shaderType,this.name=e.shaderName,this.id=Id++,this.cacheKey=t,this.usedTimes=1,this.program=p,this.vertexShader=R,this.fragmentShader=w,this}let tf=0;class ef{constructor(){this.shaderCache=new Map,this.materialCache=new Map}update(t){const e=t.vertexShader,n=t.fragmentShader,r=this._getShaderStage(e),a=this._getShaderStage(n),o=this._getShaderCacheForMaterial(t);return o.has(r)===!1&&(o.add(r),r.usedTimes++),o.has(a)===!1&&(o.add(a),a.usedTimes++),this}remove(t){const e=this.materialCache.get(t);for(const n of e)n.usedTimes--,n.usedTimes===0&&this.shaderCache.delete(n.code);return this.materialCache.delete(t),this}getVertexShaderID(t){return this._getShaderStage(t.vertexShader).id}getFragmentShaderID(t){return this._getShaderStage(t.fragmentShader).id}dispose(){this.shaderCache.clear(),this.materialCache.clear()}_getShaderCacheForMaterial(t){const e=this.materialCache;let n=e.get(t);return n===void 0&&(n=new Set,e.set(t,n)),n}_getShaderStage(t){const e=this.shaderCache;let n=e.get(t);return n===void 0&&(n=new nf(t),e.set(t,n)),n}}class nf{constructor(t){this.id=tf++,this.code=t,this.usedTimes=0}}function rf(i,t,e,n,r,a,o){const s=new Xs,l=new ef,c=[],u=r.isWebGL2,d=r.logarithmicDepthBuffer,f=r.vertexTextures;let m=r.precision;const v={MeshDepthMaterial:"depth",MeshDistanceMaterial:"distanceRGBA",MeshNormalMaterial:"normal",MeshBasicMaterial:"basic",MeshLambertMaterial:"lambert",MeshPhongMaterial:"phong",MeshToonMaterial:"toon",MeshStandardMaterial:"physical",MeshPhysicalMaterial:"physical",MeshMatcapMaterial:"matcap",LineBasicMaterial:"basic",LineDashedMaterial:"dashed",PointsMaterial:"points",ShadowMaterial:"shadow",SpriteMaterial:"sprite"};function _(y){return y===0?"uv":`uv${y}`}function p(y,M,H,k,it){const C=k.fog,z=it.geometry,V=y.isMeshStandardMaterial?k.environment:null,X=(y.isMeshStandardMaterial?e:t).get(y.envMap||V),G=X&&X.mapping===qi?X.image.height:null,W=v[y.type];y.precision!==null&&(m=r.getMaxPrecision(y.precision),m!==y.precision&&console.warn("THREE.WebGLProgram.getParameters:",y.precision,"not supported, using",m,"instead."));const q=z.morphAttributes.position||z.morphAttributes.normal||z.morphAttributes.color,Q=q!==void 0?q.length:0;let tt=0;z.morphAttributes.position!==void 0&&(tt=1),z.morphAttributes.normal!==void 0&&(tt=2),z.morphAttributes.color!==void 0&&(tt=3);let B,Y,ot,mt;if(W){const pe=Oe[W];B=pe.vertexShader,Y=pe.fragmentShader}else B=y.vertexShader,Y=y.fragmentShader,l.update(y),ot=l.getVertexShaderID(y),mt=l.getFragmentShaderID(y);const pt=i.getRenderTarget(),wt=it.isInstancedMesh===!0,Pt=it.isBatchedMesh===!0,yt=!!y.map,Bt=!!y.matcap,U=!!X,fe=!!y.aoMap,_t=!!y.lightMap,bt=!!y.bumpMap,ht=!!y.normalMap,jt=!!y.displacementMap,Ut=!!y.emissiveMap,S=!!y.metalnessMap,g=!!y.roughnessMap,N=y.anisotropy>0,K=y.clearcoat>0,j=y.iridescence>0,J=y.sheen>0,dt=y.transmission>0,st=N&&!!y.anisotropyMap,ct=K&&!!y.clearcoatMap,St=K&&!!y.clearcoatNormalMap,It=K&&!!y.clearcoatRoughnessMap,$=j&&!!y.iridescenceMap,Ht=j&&!!y.iridescenceThicknessMap,zt=J&&!!y.sheenColorMap,Et=J&&!!y.sheenRoughnessMap,gt=!!y.specularMap,ut=!!y.specularColorMap,Lt=!!y.specularIntensityMap,Vt=dt&&!!y.transmissionMap,Jt=dt&&!!y.thicknessMap,Ft=!!y.gradientMap,et=!!y.alphaMap,A=y.alphaTest>0,rt=!!y.alphaHash,at=!!y.extensions,Tt=!!z.attributes.uv1,vt=!!z.attributes.uv2,Xt=!!z.attributes.uv3;let qt=ln;return y.toneMapped&&(pt===null||pt.isXRRenderTarget===!0)&&(qt=i.toneMapping),{isWebGL2:u,shaderID:W,shaderType:y.type,shaderName:y.name,vertexShader:B,fragmentShader:Y,defines:y.defines,customVertexShaderID:ot,customFragmentShaderID:mt,isRawShaderMaterial:y.isRawShaderMaterial===!0,glslVersion:y.glslVersion,precision:m,batching:Pt,instancing:wt,instancingColor:wt&&it.instanceColor!==null,supportsVertexTextures:f,outputColorSpace:pt===null?i.outputColorSpace:pt.isXRRenderTarget===!0?pt.texture.colorSpace:Je,map:yt,matcap:Bt,envMap:U,envMapMode:U&&X.mapping,envMapCubeUVHeight:G,aoMap:fe,lightMap:_t,bumpMap:bt,normalMap:ht,displacementMap:f&&jt,emissiveMap:Ut,normalMapObjectSpace:ht&&y.normalMapType===hl,normalMapTangentSpace:ht&&y.normalMapType===ul,metalnessMap:S,roughnessMap:g,anisotropy:N,anisotropyMap:st,clearcoat:K,clearcoatMap:ct,clearcoatNormalMap:St,clearcoatRoughnessMap:It,iridescence:j,iridescenceMap:$,iridescenceThicknessMap:Ht,sheen:J,sheenColorMap:zt,sheenRoughnessMap:Et,specularMap:gt,specularColorMap:ut,specularIntensityMap:Lt,transmission:dt,transmissionMap:Vt,thicknessMap:Jt,gradientMap:Ft,opaque:y.transparent===!1&&y.blending===Wn,alphaMap:et,alphaTest:A,alphaHash:rt,combine:y.combine,mapUv:yt&&_(y.map.channel),aoMapUv:fe&&_(y.aoMap.channel),lightMapUv:_t&&_(y.lightMap.channel),bumpMapUv:bt&&_(y.bumpMap.channel),normalMapUv:ht&&_(y.normalMap.channel),displacementMapUv:jt&&_(y.displacementMap.channel),emissiveMapUv:Ut&&_(y.emissiveMap.channel),metalnessMapUv:S&&_(y.metalnessMap.channel),roughnessMapUv:g&&_(y.roughnessMap.channel),anisotropyMapUv:st&&_(y.anisotropyMap.channel),clearcoatMapUv:ct&&_(y.clearcoatMap.channel),clearcoatNormalMapUv:St&&_(y.clearcoatNormalMap.channel),clearcoatRoughnessMapUv:It&&_(y.clearcoatRoughnessMap.channel),iridescenceMapUv:$&&_(y.iridescenceMap.channel),iridescenceThicknessMapUv:Ht&&_(y.iridescenceThicknessMap.channel),sheenColorMapUv:zt&&_(y.sheenColorMap.channel),sheenRoughnessMapUv:Et&&_(y.sheenRoughnessMap.channel),specularMapUv:gt&&_(y.specularMap.channel),specularColorMapUv:ut&&_(y.specularColorMap.channel),specularIntensityMapUv:Lt&&_(y.specularIntensityMap.channel),transmissionMapUv:Vt&&_(y.transmissionMap.channel),thicknessMapUv:Jt&&_(y.thicknessMap.channel),alphaMapUv:et&&_(y.alphaMap.channel),vertexTangents:!!z.attributes.tangent&&(ht||N),vertexColors:y.vertexColors,vertexAlphas:y.vertexColors===!0&&!!z.attributes.color&&z.attributes.color.itemSize===4,vertexUv1s:Tt,vertexUv2s:vt,vertexUv3s:Xt,pointsUvs:it.isPoints===!0&&!!z.attributes.uv&&(yt||et),fog:!!C,useFog:y.fog===!0,fogExp2:C&&C.isFogExp2,flatShading:y.flatShading===!0,sizeAttenuation:y.sizeAttenuation===!0,logarithmicDepthBuffer:d,skinning:it.isSkinnedMesh===!0,morphTargets:z.morphAttributes.position!==void 0,morphNormals:z.morphAttributes.normal!==void 0,morphColors:z.morphAttributes.color!==void 0,morphTargetsCount:Q,morphTextureStride:tt,numDirLights:M.directional.length,numPointLights:M.point.length,numSpotLights:M.spot.length,numSpotLightMaps:M.spotLightMap.length,numRectAreaLights:M.rectArea.length,numHemiLights:M.hemi.length,numDirLightShadows:M.directionalShadowMap.length,numPointLightShadows:M.pointShadowMap.length,numSpotLightShadows:M.spotShadowMap.length,numSpotLightShadowsWithMaps:M.numSpotLightShadowsWithMaps,numLightProbes:M.numLightProbes,numClippingPlanes:o.numPlanes,numClipIntersection:o.numIntersection,dithering:y.dithering,shadowMapEnabled:i.shadowMap.enabled&&H.length>0,shadowMapType:i.shadowMap.type,toneMapping:qt,useLegacyLights:i._useLegacyLights,decodeVideoTexture:yt&&y.map.isVideoTexture===!0&&Gt.getTransfer(y.map.colorSpace)===$t,premultipliedAlpha:y.premultipliedAlpha,doubleSided:y.side===Ye,flipSided:y.side===xe,useDepthPacking:y.depthPacking>=0,depthPacking:y.depthPacking||0,index0AttributeName:y.index0AttributeName,extensionDerivatives:at&&y.extensions.derivatives===!0,extensionFragDepth:at&&y.extensions.fragDepth===!0,extensionDrawBuffers:at&&y.extensions.drawBuffers===!0,extensionShaderTextureLOD:at&&y.extensions.shaderTextureLOD===!0,extensionClipCullDistance:at&&y.extensions.clipCullDistance&&n.has("WEBGL_clip_cull_distance"),rendererExtensionFragDepth:u||n.has("EXT_frag_depth"),rendererExtensionDrawBuffers:u||n.has("WEBGL_draw_buffers"),rendererExtensionShaderTextureLod:u||n.has("EXT_shader_texture_lod"),rendererExtensionParallelShaderCompile:n.has("KHR_parallel_shader_compile"),customProgramCacheKey:y.customProgramCacheKey()}}function h(y){const M=[];if(y.shaderID?M.push(y.shaderID):(M.push(y.customVertexShaderID),M.push(y.customFragmentShaderID)),y.defines!==void 0)for(const H in y.defines)M.push(H),M.push(y.defines[H]);return y.isRawShaderMaterial===!1&&(E(M,y),T(M,y),M.push(i.outputColorSpace)),M.push(y.customProgramCacheKey),M.join()}function E(y,M){y.push(M.precision),y.push(M.outputColorSpace),y.push(M.envMapMode),y.push(M.envMapCubeUVHeight),y.push(M.mapUv),y.push(M.alphaMapUv),y.push(M.lightMapUv),y.push(M.aoMapUv),y.push(M.bumpMapUv),y.push(M.normalMapUv),y.push(M.displacementMapUv),y.push(M.emissiveMapUv),y.push(M.metalnessMapUv),y.push(M.roughnessMapUv),y.push(M.anisotropyMapUv),y.push(M.clearcoatMapUv),y.push(M.clearcoatNormalMapUv),y.push(M.clearcoatRoughnessMapUv),y.push(M.iridescenceMapUv),y.push(M.iridescenceThicknessMapUv),y.push(M.sheenColorMapUv),y.push(M.sheenRoughnessMapUv),y.push(M.specularMapUv),y.push(M.specularColorMapUv),y.push(M.specularIntensityMapUv),y.push(M.transmissionMapUv),y.push(M.thicknessMapUv),y.push(M.combine),y.push(M.fogExp2),y.push(M.sizeAttenuation),y.push(M.morphTargetsCount),y.push(M.morphAttributeCount),y.push(M.numDirLights),y.push(M.numPointLights),y.push(M.numSpotLights),y.push(M.numSpotLightMaps),y.push(M.numHemiLights),y.push(M.numRectAreaLights),y.push(M.numDirLightShadows),y.push(M.numPointLightShadows),y.push(M.numSpotLightShadows),y.push(M.numSpotLightShadowsWithMaps),y.push(M.numLightProbes),y.push(M.shadowMapType),y.push(M.toneMapping),y.push(M.numClippingPlanes),y.push(M.numClipIntersection),y.push(M.depthPacking)}function T(y,M){s.disableAll(),M.isWebGL2&&s.enable(0),M.supportsVertexTextures&&s.enable(1),M.instancing&&s.enable(2),M.instancingColor&&s.enable(3),M.matcap&&s.enable(4),M.envMap&&s.enable(5),M.normalMapObjectSpace&&s.enable(6),M.normalMapTangentSpace&&s.enable(7),M.clearcoat&&s.enable(8),M.iridescence&&s.enable(9),M.alphaTest&&s.enable(10),M.vertexColors&&s.enable(11),M.vertexAlphas&&s.enable(12),M.vertexUv1s&&s.enable(13),M.vertexUv2s&&s.enable(14),M.vertexUv3s&&s.enable(15),M.vertexTangents&&s.enable(16),M.anisotropy&&s.enable(17),M.alphaHash&&s.enable(18),M.batching&&s.enable(19),y.push(s.mask),s.disableAll(),M.fog&&s.enable(0),M.useFog&&s.enable(1),M.flatShading&&s.enable(2),M.logarithmicDepthBuffer&&s.enable(3),M.skinning&&s.enable(4),M.morphTargets&&s.enable(5),M.morphNormals&&s.enable(6),M.morphColors&&s.enable(7),M.premultipliedAlpha&&s.enable(8),M.shadowMapEnabled&&s.enable(9),M.useLegacyLights&&s.enable(10),M.doubleSided&&s.enable(11),M.flipSided&&s.enable(12),M.useDepthPacking&&s.enable(13),M.dithering&&s.enable(14),M.transmission&&s.enable(15),M.sheen&&s.enable(16),M.opaque&&s.enable(17),M.pointsUvs&&s.enable(18),M.decodeVideoTexture&&s.enable(19),y.push(s.mask)}function b(y){const M=v[y.type];let H;if(M){const k=Oe[M];H=Bl.clone(k.uniforms)}else H=y.uniforms;return H}function D(y,M){let H;for(let k=0,it=c.length;k<it;k++){const C=c[k];if(C.cacheKey===M){H=C,++H.usedTimes;break}}return H===void 0&&(H=new Qd(i,M,y,a),c.push(H)),H}function R(y){if(--y.usedTimes===0){const M=c.indexOf(y);c[M]=c[c.length-1],c.pop(),y.destroy()}}function w(y){l.remove(y)}function Z(){l.dispose()}return{getParameters:p,getProgramCacheKey:h,getUniforms:b,acquireProgram:D,releaseProgram:R,releaseShaderCache:w,programs:c,dispose:Z}}function af(){let i=new WeakMap;function t(a){let o=i.get(a);return o===void 0&&(o={},i.set(a,o)),o}function e(a){i.delete(a)}function n(a,o,s){i.get(a)[o]=s}function r(){i=new WeakMap}return{get:t,remove:e,update:n,dispose:r}}function sf(i,t){return i.groupOrder!==t.groupOrder?i.groupOrder-t.groupOrder:i.renderOrder!==t.renderOrder?i.renderOrder-t.renderOrder:i.material.id!==t.material.id?i.material.id-t.material.id:i.z!==t.z?i.z-t.z:i.id-t.id}function Ms(i,t){return i.groupOrder!==t.groupOrder?i.groupOrder-t.groupOrder:i.renderOrder!==t.renderOrder?i.renderOrder-t.renderOrder:i.z!==t.z?t.z-i.z:i.id-t.id}function Es(){const i=[];let t=0;const e=[],n=[],r=[];function a(){t=0,e.length=0,n.length=0,r.length=0}function o(d,f,m,v,_,p){let h=i[t];return h===void 0?(h={id:d.id,object:d,geometry:f,material:m,groupOrder:v,renderOrder:d.renderOrder,z:_,group:p},i[t]=h):(h.id=d.id,h.object=d,h.geometry=f,h.material=m,h.groupOrder=v,h.renderOrder=d.renderOrder,h.z=_,h.group=p),t++,h}function s(d,f,m,v,_,p){const h=o(d,f,m,v,_,p);m.transmission>0?n.push(h):m.transparent===!0?r.push(h):e.push(h)}function l(d,f,m,v,_,p){const h=o(d,f,m,v,_,p);m.transmission>0?n.unshift(h):m.transparent===!0?r.unshift(h):e.unshift(h)}function c(d,f){e.length>1&&e.sort(d||sf),n.length>1&&n.sort(f||Ms),r.length>1&&r.sort(f||Ms)}function u(){for(let d=t,f=i.length;d<f;d++){const m=i[d];if(m.id===null)break;m.id=null,m.object=null,m.geometry=null,m.material=null,m.group=null}}return{opaque:e,transmissive:n,transparent:r,init:a,push:s,unshift:l,finish:u,sort:c}}function of(){let i=new WeakMap;function t(n,r){const a=i.get(n);let o;return a===void 0?(o=new Es,i.set(n,[o])):r>=a.length?(o=new Es,a.push(o)):o=a[r],o}function e(){i=new WeakMap}return{get:t,dispose:e}}function lf(){const i={};return{get:function(t){if(i[t.id]!==void 0)return i[t.id];let e;switch(t.type){case"DirectionalLight":e={direction:new L,color:new kt};break;case"SpotLight":e={position:new L,direction:new L,color:new kt,distance:0,coneCos:0,penumbraCos:0,decay:0};break;case"PointLight":e={position:new L,color:new kt,distance:0,decay:0};break;case"HemisphereLight":e={direction:new L,skyColor:new kt,groundColor:new kt};break;case"RectAreaLight":e={color:new kt,position:new L,halfWidth:new L,halfHeight:new L};break}return i[t.id]=e,e}}}function cf(){const i={};return{get:function(t){if(i[t.id]!==void 0)return i[t.id];let e;switch(t.type){case"DirectionalLight":e={shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new Wt};break;case"SpotLight":e={shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new Wt};break;case"PointLight":e={shadowBias:0,shadowNormalBias:0,shadowRadius:1,shadowMapSize:new Wt,shadowCameraNear:1,shadowCameraFar:1e3};break}return i[t.id]=e,e}}}let uf=0;function hf(i,t){return(t.castShadow?2:0)-(i.castShadow?2:0)+(t.map?1:0)-(i.map?1:0)}function df(i,t){const e=new lf,n=cf(),r={version:0,hash:{directionalLength:-1,pointLength:-1,spotLength:-1,rectAreaLength:-1,hemiLength:-1,numDirectionalShadows:-1,numPointShadows:-1,numSpotShadows:-1,numSpotMaps:-1,numLightProbes:-1},ambient:[0,0,0],probe:[],directional:[],directionalShadow:[],directionalShadowMap:[],directionalShadowMatrix:[],spot:[],spotLightMap:[],spotShadow:[],spotShadowMap:[],spotLightMatrix:[],rectArea:[],rectAreaLTC1:null,rectAreaLTC2:null,point:[],pointShadow:[],pointShadowMap:[],pointShadowMatrix:[],hemi:[],numSpotLightShadowsWithMaps:0,numLightProbes:0};for(let u=0;u<9;u++)r.probe.push(new L);const a=new L,o=new Kt,s=new Kt;function l(u,d){let f=0,m=0,v=0;for(let k=0;k<9;k++)r.probe[k].set(0,0,0);let _=0,p=0,h=0,E=0,T=0,b=0,D=0,R=0,w=0,Z=0,y=0;u.sort(hf);const M=d===!0?Math.PI:1;for(let k=0,it=u.length;k<it;k++){const C=u[k],z=C.color,V=C.intensity,X=C.distance,G=C.shadow&&C.shadow.map?C.shadow.map.texture:null;if(C.isAmbientLight)f+=z.r*V*M,m+=z.g*V*M,v+=z.b*V*M;else if(C.isLightProbe){for(let W=0;W<9;W++)r.probe[W].addScaledVector(C.sh.coefficients[W],V);y++}else if(C.isDirectionalLight){const W=e.get(C);if(W.color.copy(C.color).multiplyScalar(C.intensity*M),C.castShadow){const q=C.shadow,Q=n.get(C);Q.shadowBias=q.bias,Q.shadowNormalBias=q.normalBias,Q.shadowRadius=q.radius,Q.shadowMapSize=q.mapSize,r.directionalShadow[_]=Q,r.directionalShadowMap[_]=G,r.directionalShadowMatrix[_]=C.shadow.matrix,b++}r.directional[_]=W,_++}else if(C.isSpotLight){const W=e.get(C);W.position.setFromMatrixPosition(C.matrixWorld),W.color.copy(z).multiplyScalar(V*M),W.distance=X,W.coneCos=Math.cos(C.angle),W.penumbraCos=Math.cos(C.angle*(1-C.penumbra)),W.decay=C.decay,r.spot[h]=W;const q=C.shadow;if(C.map&&(r.spotLightMap[w]=C.map,w++,q.updateMatrices(C),C.castShadow&&Z++),r.spotLightMatrix[h]=q.matrix,C.castShadow){const Q=n.get(C);Q.shadowBias=q.bias,Q.shadowNormalBias=q.normalBias,Q.shadowRadius=q.radius,Q.shadowMapSize=q.mapSize,r.spotShadow[h]=Q,r.spotShadowMap[h]=G,R++}h++}else if(C.isRectAreaLight){const W=e.get(C);W.color.copy(z).multiplyScalar(V),W.halfWidth.set(C.width*.5,0,0),W.halfHeight.set(0,C.height*.5,0),r.rectArea[E]=W,E++}else if(C.isPointLight){const W=e.get(C);if(W.color.copy(C.color).multiplyScalar(C.intensity*M),W.distance=C.distance,W.decay=C.decay,C.castShadow){const q=C.shadow,Q=n.get(C);Q.shadowBias=q.bias,Q.shadowNormalBias=q.normalBias,Q.shadowRadius=q.radius,Q.shadowMapSize=q.mapSize,Q.shadowCameraNear=q.camera.near,Q.shadowCameraFar=q.camera.far,r.pointShadow[p]=Q,r.pointShadowMap[p]=G,r.pointShadowMatrix[p]=C.shadow.matrix,D++}r.point[p]=W,p++}else if(C.isHemisphereLight){const W=e.get(C);W.skyColor.copy(C.color).multiplyScalar(V*M),W.groundColor.copy(C.groundColor).multiplyScalar(V*M),r.hemi[T]=W,T++}}E>0&&(t.isWebGL2?i.has("OES_texture_float_linear")===!0?(r.rectAreaLTC1=nt.LTC_FLOAT_1,r.rectAreaLTC2=nt.LTC_FLOAT_2):(r.rectAreaLTC1=nt.LTC_HALF_1,r.rectAreaLTC2=nt.LTC_HALF_2):i.has("OES_texture_float_linear")===!0?(r.rectAreaLTC1=nt.LTC_FLOAT_1,r.rectAreaLTC2=nt.LTC_FLOAT_2):i.has("OES_texture_half_float_linear")===!0?(r.rectAreaLTC1=nt.LTC_HALF_1,r.rectAreaLTC2=nt.LTC_HALF_2):console.error("THREE.WebGLRenderer: Unable to use RectAreaLight. Missing WebGL extensions.")),r.ambient[0]=f,r.ambient[1]=m,r.ambient[2]=v;const H=r.hash;(H.directionalLength!==_||H.pointLength!==p||H.spotLength!==h||H.rectAreaLength!==E||H.hemiLength!==T||H.numDirectionalShadows!==b||H.numPointShadows!==D||H.numSpotShadows!==R||H.numSpotMaps!==w||H.numLightProbes!==y)&&(r.directional.length=_,r.spot.length=h,r.rectArea.length=E,r.point.length=p,r.hemi.length=T,r.directionalShadow.length=b,r.directionalShadowMap.length=b,r.pointShadow.length=D,r.pointShadowMap.length=D,r.spotShadow.length=R,r.spotShadowMap.length=R,r.directionalShadowMatrix.length=b,r.pointShadowMatrix.length=D,r.spotLightMatrix.length=R+w-Z,r.spotLightMap.length=w,r.numSpotLightShadowsWithMaps=Z,r.numLightProbes=y,H.directionalLength=_,H.pointLength=p,H.spotLength=h,H.rectAreaLength=E,H.hemiLength=T,H.numDirectionalShadows=b,H.numPointShadows=D,H.numSpotShadows=R,H.numSpotMaps=w,H.numLightProbes=y,r.version=uf++)}function c(u,d){let f=0,m=0,v=0,_=0,p=0;const h=d.matrixWorldInverse;for(let E=0,T=u.length;E<T;E++){const b=u[E];if(b.isDirectionalLight){const D=r.directional[f];D.direction.setFromMatrixPosition(b.matrixWorld),a.setFromMatrixPosition(b.target.matrixWorld),D.direction.sub(a),D.direction.transformDirection(h),f++}else if(b.isSpotLight){const D=r.spot[v];D.position.setFromMatrixPosition(b.matrixWorld),D.position.applyMatrix4(h),D.direction.setFromMatrixPosition(b.matrixWorld),a.setFromMatrixPosition(b.target.matrixWorld),D.direction.sub(a),D.direction.transformDirection(h),v++}else if(b.isRectAreaLight){const D=r.rectArea[_];D.position.setFromMatrixPosition(b.matrixWorld),D.position.applyMatrix4(h),s.identity(),o.copy(b.matrixWorld),o.premultiply(h),s.extractRotation(o),D.halfWidth.set(b.width*.5,0,0),D.halfHeight.set(0,b.height*.5,0),D.halfWidth.applyMatrix4(s),D.halfHeight.applyMatrix4(s),_++}else if(b.isPointLight){const D=r.point[m];D.position.setFromMatrixPosition(b.matrixWorld),D.position.applyMatrix4(h),m++}else if(b.isHemisphereLight){const D=r.hemi[p];D.direction.setFromMatrixPosition(b.matrixWorld),D.direction.transformDirection(h),p++}}}return{setup:l,setupView:c,state:r}}function bs(i,t){const e=new df(i,t),n=[],r=[];function a(){n.length=0,r.length=0}function o(d){n.push(d)}function s(d){r.push(d)}function l(d){e.setup(n,d)}function c(d){e.setupView(n,d)}return{init:a,state:{lightsArray:n,shadowsArray:r,lights:e},setupLights:l,setupLightsView:c,pushLight:o,pushShadow:s}}function ff(i,t){let e=new WeakMap;function n(a,o=0){const s=e.get(a);let l;return s===void 0?(l=new bs(i,t),e.set(a,[l])):o>=s.length?(l=new bs(i,t),s.push(l)):l=s[o],l}function r(){e=new WeakMap}return{get:n,dispose:r}}class pf extends ji{constructor(t){super(),this.isMeshDepthMaterial=!0,this.type="MeshDepthMaterial",this.depthPacking=ll,this.map=null,this.alphaMap=null,this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.wireframe=!1,this.wireframeLinewidth=1,this.setValues(t)}copy(t){return super.copy(t),this.depthPacking=t.depthPacking,this.map=t.map,this.alphaMap=t.alphaMap,this.displacementMap=t.displacementMap,this.displacementScale=t.displacementScale,this.displacementBias=t.displacementBias,this.wireframe=t.wireframe,this.wireframeLinewidth=t.wireframeLinewidth,this}}class mf extends ji{constructor(t){super(),this.isMeshDistanceMaterial=!0,this.type="MeshDistanceMaterial",this.map=null,this.alphaMap=null,this.displacementMap=null,this.displacementScale=1,this.displacementBias=0,this.setValues(t)}copy(t){return super.copy(t),this.map=t.map,this.alphaMap=t.alphaMap,this.displacementMap=t.displacementMap,this.displacementScale=t.displacementScale,this.displacementBias=t.displacementBias,this}}const gf=`void main() {
	gl_Position = vec4( position, 1.0 );
}`,_f=`uniform sampler2D shadow_pass;
uniform vec2 resolution;
uniform float radius;
#include <packing>
void main() {
	const float samples = float( VSM_SAMPLES );
	float mean = 0.0;
	float squared_mean = 0.0;
	float uvStride = samples <= 1.0 ? 0.0 : 2.0 / ( samples - 1.0 );
	float uvStart = samples <= 1.0 ? 0.0 : - 1.0;
	for ( float i = 0.0; i < samples; i ++ ) {
		float uvOffset = uvStart + i * uvStride;
		#ifdef HORIZONTAL_PASS
			vec2 distribution = unpackRGBATo2Half( texture2D( shadow_pass, ( gl_FragCoord.xy + vec2( uvOffset, 0.0 ) * radius ) / resolution ) );
			mean += distribution.x;
			squared_mean += distribution.y * distribution.y + distribution.x * distribution.x;
		#else
			float depth = unpackRGBAToDepth( texture2D( shadow_pass, ( gl_FragCoord.xy + vec2( 0.0, uvOffset ) * radius ) / resolution ) );
			mean += depth;
			squared_mean += depth * depth;
		#endif
	}
	mean = mean / samples;
	squared_mean = squared_mean / samples;
	float std_dev = sqrt( squared_mean - mean * mean );
	gl_FragColor = pack2HalfToRGBA( vec2( mean, std_dev ) );
}`;function vf(i,t,e){let n=new Qs;const r=new Wt,a=new Wt,o=new ce,s=new pf({depthPacking:cl}),l=new mf,c={},u=e.maxTextureSize,d={[un]:xe,[xe]:un,[Ye]:Ye},f=new hn({defines:{VSM_SAMPLES:8},uniforms:{shadow_pass:{value:null},resolution:{value:new Wt},radius:{value:4}},vertexShader:gf,fragmentShader:_f}),m=f.clone();m.defines.HORIZONTAL_PASS=1;const v=new dn;v.setAttribute("position",new ze(new Float32Array([-1,-1,.5,3,-1,.5,-1,3,.5]),3));const _=new Ze(v,f),p=this;this.enabled=!1,this.autoUpdate=!0,this.needsUpdate=!1,this.type=Cs;let h=this.type;this.render=function(R,w,Z){if(p.enabled===!1||p.autoUpdate===!1&&p.needsUpdate===!1||R.length===0)return;const y=i.getRenderTarget(),M=i.getActiveCubeFace(),H=i.getActiveMipmapLevel(),k=i.state;k.setBlending(on),k.buffers.color.setClear(1,1,1,1),k.buffers.depth.setTest(!0),k.setScissorTest(!1);const it=h!==qe&&this.type===qe,C=h===qe&&this.type!==qe;for(let z=0,V=R.length;z<V;z++){const X=R[z],G=X.shadow;if(G===void 0){console.warn("THREE.WebGLShadowMap:",X,"has no shadow.");continue}if(G.autoUpdate===!1&&G.needsUpdate===!1)continue;r.copy(G.mapSize);const W=G.getFrameExtents();if(r.multiply(W),a.copy(G.mapSize),(r.x>u||r.y>u)&&(r.x>u&&(a.x=Math.floor(u/W.x),r.x=a.x*W.x,G.mapSize.x=a.x),r.y>u&&(a.y=Math.floor(u/W.y),r.y=a.y*W.y,G.mapSize.y=a.y)),G.map===null||it===!0||C===!0){const Q=this.type!==qe?{minFilter:oe,magFilter:oe}:{};G.map!==null&&G.map.dispose(),G.map=new Qe(r.x,r.y,Q),G.map.texture.name=X.name+".shadowMap",G.camera.updateProjectionMatrix()}i.setRenderTarget(G.map),i.clear();const q=G.getViewportCount();for(let Q=0;Q<q;Q++){const tt=G.getViewport(Q);o.set(a.x*tt.x,a.y*tt.y,a.x*tt.z,a.y*tt.w),k.viewport(o),G.updateMatrices(X,Q),n=G.getFrustum(),b(w,Z,G.camera,X,this.type)}G.isPointLightShadow!==!0&&this.type===qe&&E(G,Z),G.needsUpdate=!1}h=this.type,p.needsUpdate=!1,i.setRenderTarget(y,M,H)};function E(R,w){const Z=t.update(_);f.defines.VSM_SAMPLES!==R.blurSamples&&(f.defines.VSM_SAMPLES=R.blurSamples,m.defines.VSM_SAMPLES=R.blurSamples,f.needsUpdate=!0,m.needsUpdate=!0),R.mapPass===null&&(R.mapPass=new Qe(r.x,r.y)),f.uniforms.shadow_pass.value=R.map.texture,f.uniforms.resolution.value=R.mapSize,f.uniforms.radius.value=R.radius,i.setRenderTarget(R.mapPass),i.clear(),i.renderBufferDirect(w,null,Z,f,_,null),m.uniforms.shadow_pass.value=R.mapPass.texture,m.uniforms.resolution.value=R.mapSize,m.uniforms.radius.value=R.radius,i.setRenderTarget(R.map),i.clear(),i.renderBufferDirect(w,null,Z,m,_,null)}function T(R,w,Z,y){let M=null;const H=Z.isPointLight===!0?R.customDistanceMaterial:R.customDepthMaterial;if(H!==void 0)M=H;else if(M=Z.isPointLight===!0?l:s,i.localClippingEnabled&&w.clipShadows===!0&&Array.isArray(w.clippingPlanes)&&w.clippingPlanes.length!==0||w.displacementMap&&w.displacementScale!==0||w.alphaMap&&w.alphaTest>0||w.map&&w.alphaTest>0){const k=M.uuid,it=w.uuid;let C=c[k];C===void 0&&(C={},c[k]=C);let z=C[it];z===void 0&&(z=M.clone(),C[it]=z,w.addEventListener("dispose",D)),M=z}if(M.visible=w.visible,M.wireframe=w.wireframe,y===qe?M.side=w.shadowSide!==null?w.shadowSide:w.side:M.side=w.shadowSide!==null?w.shadowSide:d[w.side],M.alphaMap=w.alphaMap,M.alphaTest=w.alphaTest,M.map=w.map,M.clipShadows=w.clipShadows,M.clippingPlanes=w.clippingPlanes,M.clipIntersection=w.clipIntersection,M.displacementMap=w.displacementMap,M.displacementScale=w.displacementScale,M.displacementBias=w.displacementBias,M.wireframeLinewidth=w.wireframeLinewidth,M.linewidth=w.linewidth,Z.isPointLight===!0&&M.isMeshDistanceMaterial===!0){const k=i.properties.get(M);k.light=Z}return M}function b(R,w,Z,y,M){if(R.visible===!1)return;if(R.layers.test(w.layers)&&(R.isMesh||R.isLine||R.isPoints)&&(R.castShadow||R.receiveShadow&&M===qe)&&(!R.frustumCulled||n.intersectsObject(R))){R.modelViewMatrix.multiplyMatrices(Z.matrixWorldInverse,R.matrixWorld);const it=t.update(R),C=R.material;if(Array.isArray(C)){const z=it.groups;for(let V=0,X=z.length;V<X;V++){const G=z[V],W=C[G.materialIndex];if(W&&W.visible){const q=T(R,W,y,M);R.onBeforeShadow(i,R,w,Z,it,q,G),i.renderBufferDirect(Z,null,it,q,R,G),R.onAfterShadow(i,R,w,Z,it,q,G)}}}else if(C.visible){const z=T(R,C,y,M);R.onBeforeShadow(i,R,w,Z,it,z,null),i.renderBufferDirect(Z,null,it,z,R,null),R.onAfterShadow(i,R,w,Z,it,z,null)}}const k=R.children;for(let it=0,C=k.length;it<C;it++)b(k[it],w,Z,y,M)}function D(R){R.target.removeEventListener("dispose",D);for(const Z in c){const y=c[Z],M=R.target.uuid;M in y&&(y[M].dispose(),delete y[M])}}}function xf(i,t,e){const n=e.isWebGL2;function r(){let A=!1;const rt=new ce;let at=null;const Tt=new ce(0,0,0,0);return{setMask:function(vt){at!==vt&&!A&&(i.colorMask(vt,vt,vt,vt),at=vt)},setLocked:function(vt){A=vt},setClear:function(vt,Xt,qt,re,pe){pe===!0&&(vt*=re,Xt*=re,qt*=re),rt.set(vt,Xt,qt,re),Tt.equals(rt)===!1&&(i.clearColor(vt,Xt,qt,re),Tt.copy(rt))},reset:function(){A=!1,at=null,Tt.set(-1,0,0,0)}}}function a(){let A=!1,rt=null,at=null,Tt=null;return{setTest:function(vt){vt?Pt(i.DEPTH_TEST):yt(i.DEPTH_TEST)},setMask:function(vt){rt!==vt&&!A&&(i.depthMask(vt),rt=vt)},setFunc:function(vt){if(at!==vt){switch(vt){case zo:i.depthFunc(i.NEVER);break;case Bo:i.depthFunc(i.ALWAYS);break;case Vo:i.depthFunc(i.LESS);break;case Vi:i.depthFunc(i.LEQUAL);break;case Ho:i.depthFunc(i.EQUAL);break;case Go:i.depthFunc(i.GEQUAL);break;case ko:i.depthFunc(i.GREATER);break;case Wo:i.depthFunc(i.NOTEQUAL);break;default:i.depthFunc(i.LEQUAL)}at=vt}},setLocked:function(vt){A=vt},setClear:function(vt){Tt!==vt&&(i.clearDepth(vt),Tt=vt)},reset:function(){A=!1,rt=null,at=null,Tt=null}}}function o(){let A=!1,rt=null,at=null,Tt=null,vt=null,Xt=null,qt=null,re=null,pe=null;return{setTest:function(Yt){A||(Yt?Pt(i.STENCIL_TEST):yt(i.STENCIL_TEST))},setMask:function(Yt){rt!==Yt&&!A&&(i.stencilMask(Yt),rt=Yt)},setFunc:function(Yt,me,Fe){(at!==Yt||Tt!==me||vt!==Fe)&&(i.stencilFunc(Yt,me,Fe),at=Yt,Tt=me,vt=Fe)},setOp:function(Yt,me,Fe){(Xt!==Yt||qt!==me||re!==Fe)&&(i.stencilOp(Yt,me,Fe),Xt=Yt,qt=me,re=Fe)},setLocked:function(Yt){A=Yt},setClear:function(Yt){pe!==Yt&&(i.clearStencil(Yt),pe=Yt)},reset:function(){A=!1,rt=null,at=null,Tt=null,vt=null,Xt=null,qt=null,re=null,pe=null}}}const s=new r,l=new a,c=new o,u=new WeakMap,d=new WeakMap;let f={},m={},v=new WeakMap,_=[],p=null,h=!1,E=null,T=null,b=null,D=null,R=null,w=null,Z=null,y=new kt(0,0,0),M=0,H=!1,k=null,it=null,C=null,z=null,V=null;const X=i.getParameter(i.MAX_COMBINED_TEXTURE_IMAGE_UNITS);let G=!1,W=0;const q=i.getParameter(i.VERSION);q.indexOf("WebGL")!==-1?(W=parseFloat(/^WebGL (\d)/.exec(q)[1]),G=W>=1):q.indexOf("OpenGL ES")!==-1&&(W=parseFloat(/^OpenGL ES (\d)/.exec(q)[1]),G=W>=2);let Q=null,tt={};const B=i.getParameter(i.SCISSOR_BOX),Y=i.getParameter(i.VIEWPORT),ot=new ce().fromArray(B),mt=new ce().fromArray(Y);function pt(A,rt,at,Tt){const vt=new Uint8Array(4),Xt=i.createTexture();i.bindTexture(A,Xt),i.texParameteri(A,i.TEXTURE_MIN_FILTER,i.NEAREST),i.texParameteri(A,i.TEXTURE_MAG_FILTER,i.NEAREST);for(let qt=0;qt<at;qt++)n&&(A===i.TEXTURE_3D||A===i.TEXTURE_2D_ARRAY)?i.texImage3D(rt,0,i.RGBA,1,1,Tt,0,i.RGBA,i.UNSIGNED_BYTE,vt):i.texImage2D(rt+qt,0,i.RGBA,1,1,0,i.RGBA,i.UNSIGNED_BYTE,vt);return Xt}const wt={};wt[i.TEXTURE_2D]=pt(i.TEXTURE_2D,i.TEXTURE_2D,1),wt[i.TEXTURE_CUBE_MAP]=pt(i.TEXTURE_CUBE_MAP,i.TEXTURE_CUBE_MAP_POSITIVE_X,6),n&&(wt[i.TEXTURE_2D_ARRAY]=pt(i.TEXTURE_2D_ARRAY,i.TEXTURE_2D_ARRAY,1,1),wt[i.TEXTURE_3D]=pt(i.TEXTURE_3D,i.TEXTURE_3D,1,1)),s.setClear(0,0,0,1),l.setClear(1),c.setClear(0),Pt(i.DEPTH_TEST),l.setFunc(Vi),Ut(!1),S(sa),Pt(i.CULL_FACE),ht(on);function Pt(A){f[A]!==!0&&(i.enable(A),f[A]=!0)}function yt(A){f[A]!==!1&&(i.disable(A),f[A]=!1)}function Bt(A,rt){return m[A]!==rt?(i.bindFramebuffer(A,rt),m[A]=rt,n&&(A===i.DRAW_FRAMEBUFFER&&(m[i.FRAMEBUFFER]=rt),A===i.FRAMEBUFFER&&(m[i.DRAW_FRAMEBUFFER]=rt)),!0):!1}function U(A,rt){let at=_,Tt=!1;if(A)if(at=v.get(rt),at===void 0&&(at=[],v.set(rt,at)),A.isWebGLMultipleRenderTargets){const vt=A.texture;if(at.length!==vt.length||at[0]!==i.COLOR_ATTACHMENT0){for(let Xt=0,qt=vt.length;Xt<qt;Xt++)at[Xt]=i.COLOR_ATTACHMENT0+Xt;at.length=vt.length,Tt=!0}}else at[0]!==i.COLOR_ATTACHMENT0&&(at[0]=i.COLOR_ATTACHMENT0,Tt=!0);else at[0]!==i.BACK&&(at[0]=i.BACK,Tt=!0);Tt&&(e.isWebGL2?i.drawBuffers(at):t.get("WEBGL_draw_buffers").drawBuffersWEBGL(at))}function fe(A){return p!==A?(i.useProgram(A),p=A,!0):!1}const _t={[yn]:i.FUNC_ADD,[Mo]:i.FUNC_SUBTRACT,[Eo]:i.FUNC_REVERSE_SUBTRACT};if(n)_t[ua]=i.MIN,_t[ha]=i.MAX;else{const A=t.get("EXT_blend_minmax");A!==null&&(_t[ua]=A.MIN_EXT,_t[ha]=A.MAX_EXT)}const bt={[bo]:i.ZERO,[Ao]:i.ONE,[wo]:i.SRC_COLOR,[Ir]:i.SRC_ALPHA,[Uo]:i.SRC_ALPHA_SATURATE,[Lo]:i.DST_COLOR,[Co]:i.DST_ALPHA,[Ro]:i.ONE_MINUS_SRC_COLOR,[Nr]:i.ONE_MINUS_SRC_ALPHA,[Do]:i.ONE_MINUS_DST_COLOR,[Po]:i.ONE_MINUS_DST_ALPHA,[Io]:i.CONSTANT_COLOR,[No]:i.ONE_MINUS_CONSTANT_COLOR,[Fo]:i.CONSTANT_ALPHA,[Oo]:i.ONE_MINUS_CONSTANT_ALPHA};function ht(A,rt,at,Tt,vt,Xt,qt,re,pe,Yt){if(A===on){h===!0&&(yt(i.BLEND),h=!1);return}if(h===!1&&(Pt(i.BLEND),h=!0),A!==To){if(A!==E||Yt!==H){if((T!==yn||R!==yn)&&(i.blendEquation(i.FUNC_ADD),T=yn,R=yn),Yt)switch(A){case Wn:i.blendFuncSeparate(i.ONE,i.ONE_MINUS_SRC_ALPHA,i.ONE,i.ONE_MINUS_SRC_ALPHA);break;case oa:i.blendFunc(i.ONE,i.ONE);break;case la:i.blendFuncSeparate(i.ZERO,i.ONE_MINUS_SRC_COLOR,i.ZERO,i.ONE);break;case ca:i.blendFuncSeparate(i.ZERO,i.SRC_COLOR,i.ZERO,i.SRC_ALPHA);break;default:console.error("THREE.WebGLState: Invalid blending: ",A);break}else switch(A){case Wn:i.blendFuncSeparate(i.SRC_ALPHA,i.ONE_MINUS_SRC_ALPHA,i.ONE,i.ONE_MINUS_SRC_ALPHA);break;case oa:i.blendFunc(i.SRC_ALPHA,i.ONE);break;case la:i.blendFuncSeparate(i.ZERO,i.ONE_MINUS_SRC_COLOR,i.ZERO,i.ONE);break;case ca:i.blendFunc(i.ZERO,i.SRC_COLOR);break;default:console.error("THREE.WebGLState: Invalid blending: ",A);break}b=null,D=null,w=null,Z=null,y.set(0,0,0),M=0,E=A,H=Yt}return}vt=vt||rt,Xt=Xt||at,qt=qt||Tt,(rt!==T||vt!==R)&&(i.blendEquationSeparate(_t[rt],_t[vt]),T=rt,R=vt),(at!==b||Tt!==D||Xt!==w||qt!==Z)&&(i.blendFuncSeparate(bt[at],bt[Tt],bt[Xt],bt[qt]),b=at,D=Tt,w=Xt,Z=qt),(re.equals(y)===!1||pe!==M)&&(i.blendColor(re.r,re.g,re.b,pe),y.copy(re),M=pe),E=A,H=!1}function jt(A,rt){A.side===Ye?yt(i.CULL_FACE):Pt(i.CULL_FACE);let at=A.side===xe;rt&&(at=!at),Ut(at),A.blending===Wn&&A.transparent===!1?ht(on):ht(A.blending,A.blendEquation,A.blendSrc,A.blendDst,A.blendEquationAlpha,A.blendSrcAlpha,A.blendDstAlpha,A.blendColor,A.blendAlpha,A.premultipliedAlpha),l.setFunc(A.depthFunc),l.setTest(A.depthTest),l.setMask(A.depthWrite),s.setMask(A.colorWrite);const Tt=A.stencilWrite;c.setTest(Tt),Tt&&(c.setMask(A.stencilWriteMask),c.setFunc(A.stencilFunc,A.stencilRef,A.stencilFuncMask),c.setOp(A.stencilFail,A.stencilZFail,A.stencilZPass)),N(A.polygonOffset,A.polygonOffsetFactor,A.polygonOffsetUnits),A.alphaToCoverage===!0?Pt(i.SAMPLE_ALPHA_TO_COVERAGE):yt(i.SAMPLE_ALPHA_TO_COVERAGE)}function Ut(A){k!==A&&(A?i.frontFace(i.CW):i.frontFace(i.CCW),k=A)}function S(A){A!==xo?(Pt(i.CULL_FACE),A!==it&&(A===sa?i.cullFace(i.BACK):A===So?i.cullFace(i.FRONT):i.cullFace(i.FRONT_AND_BACK))):yt(i.CULL_FACE),it=A}function g(A){A!==C&&(G&&i.lineWidth(A),C=A)}function N(A,rt,at){A?(Pt(i.POLYGON_OFFSET_FILL),(z!==rt||V!==at)&&(i.polygonOffset(rt,at),z=rt,V=at)):yt(i.POLYGON_OFFSET_FILL)}function K(A){A?Pt(i.SCISSOR_TEST):yt(i.SCISSOR_TEST)}function j(A){A===void 0&&(A=i.TEXTURE0+X-1),Q!==A&&(i.activeTexture(A),Q=A)}function J(A,rt,at){at===void 0&&(Q===null?at=i.TEXTURE0+X-1:at=Q);let Tt=tt[at];Tt===void 0&&(Tt={type:void 0,texture:void 0},tt[at]=Tt),(Tt.type!==A||Tt.texture!==rt)&&(Q!==at&&(i.activeTexture(at),Q=at),i.bindTexture(A,rt||wt[A]),Tt.type=A,Tt.texture=rt)}function dt(){const A=tt[Q];A!==void 0&&A.type!==void 0&&(i.bindTexture(A.type,null),A.type=void 0,A.texture=void 0)}function st(){try{i.compressedTexImage2D.apply(i,arguments)}catch(A){console.error("THREE.WebGLState:",A)}}function ct(){try{i.compressedTexImage3D.apply(i,arguments)}catch(A){console.error("THREE.WebGLState:",A)}}function St(){try{i.texSubImage2D.apply(i,arguments)}catch(A){console.error("THREE.WebGLState:",A)}}function It(){try{i.texSubImage3D.apply(i,arguments)}catch(A){console.error("THREE.WebGLState:",A)}}function $(){try{i.compressedTexSubImage2D.apply(i,arguments)}catch(A){console.error("THREE.WebGLState:",A)}}function Ht(){try{i.compressedTexSubImage3D.apply(i,arguments)}catch(A){console.error("THREE.WebGLState:",A)}}function zt(){try{i.texStorage2D.apply(i,arguments)}catch(A){console.error("THREE.WebGLState:",A)}}function Et(){try{i.texStorage3D.apply(i,arguments)}catch(A){console.error("THREE.WebGLState:",A)}}function gt(){try{i.texImage2D.apply(i,arguments)}catch(A){console.error("THREE.WebGLState:",A)}}function ut(){try{i.texImage3D.apply(i,arguments)}catch(A){console.error("THREE.WebGLState:",A)}}function Lt(A){ot.equals(A)===!1&&(i.scissor(A.x,A.y,A.z,A.w),ot.copy(A))}function Vt(A){mt.equals(A)===!1&&(i.viewport(A.x,A.y,A.z,A.w),mt.copy(A))}function Jt(A,rt){let at=d.get(rt);at===void 0&&(at=new WeakMap,d.set(rt,at));let Tt=at.get(A);Tt===void 0&&(Tt=i.getUniformBlockIndex(rt,A.name),at.set(A,Tt))}function Ft(A,rt){const Tt=d.get(rt).get(A);u.get(rt)!==Tt&&(i.uniformBlockBinding(rt,Tt,A.__bindingPointIndex),u.set(rt,Tt))}function et(){i.disable(i.BLEND),i.disable(i.CULL_FACE),i.disable(i.DEPTH_TEST),i.disable(i.POLYGON_OFFSET_FILL),i.disable(i.SCISSOR_TEST),i.disable(i.STENCIL_TEST),i.disable(i.SAMPLE_ALPHA_TO_COVERAGE),i.blendEquation(i.FUNC_ADD),i.blendFunc(i.ONE,i.ZERO),i.blendFuncSeparate(i.ONE,i.ZERO,i.ONE,i.ZERO),i.blendColor(0,0,0,0),i.colorMask(!0,!0,!0,!0),i.clearColor(0,0,0,0),i.depthMask(!0),i.depthFunc(i.LESS),i.clearDepth(1),i.stencilMask(4294967295),i.stencilFunc(i.ALWAYS,0,4294967295),i.stencilOp(i.KEEP,i.KEEP,i.KEEP),i.clearStencil(0),i.cullFace(i.BACK),i.frontFace(i.CCW),i.polygonOffset(0,0),i.activeTexture(i.TEXTURE0),i.bindFramebuffer(i.FRAMEBUFFER,null),n===!0&&(i.bindFramebuffer(i.DRAW_FRAMEBUFFER,null),i.bindFramebuffer(i.READ_FRAMEBUFFER,null)),i.useProgram(null),i.lineWidth(1),i.scissor(0,0,i.canvas.width,i.canvas.height),i.viewport(0,0,i.canvas.width,i.canvas.height),f={},Q=null,tt={},m={},v=new WeakMap,_=[],p=null,h=!1,E=null,T=null,b=null,D=null,R=null,w=null,Z=null,y=new kt(0,0,0),M=0,H=!1,k=null,it=null,C=null,z=null,V=null,ot.set(0,0,i.canvas.width,i.canvas.height),mt.set(0,0,i.canvas.width,i.canvas.height),s.reset(),l.reset(),c.reset()}return{buffers:{color:s,depth:l,stencil:c},enable:Pt,disable:yt,bindFramebuffer:Bt,drawBuffers:U,useProgram:fe,setBlending:ht,setMaterial:jt,setFlipSided:Ut,setCullFace:S,setLineWidth:g,setPolygonOffset:N,setScissorTest:K,activeTexture:j,bindTexture:J,unbindTexture:dt,compressedTexImage2D:st,compressedTexImage3D:ct,texImage2D:gt,texImage3D:ut,updateUBOMapping:Jt,uniformBlockBinding:Ft,texStorage2D:zt,texStorage3D:Et,texSubImage2D:St,texSubImage3D:It,compressedTexSubImage2D:$,compressedTexSubImage3D:Ht,scissor:Lt,viewport:Vt,reset:et}}function Sf(i,t,e,n,r,a,o){const s=r.isWebGL2,l=t.has("WEBGL_multisampled_render_to_texture")?t.get("WEBGL_multisampled_render_to_texture"):null,c=typeof navigator>"u"?!1:/OculusBrowser/g.test(navigator.userAgent),u=new WeakMap;let d;const f=new WeakMap;let m=!1;try{m=typeof OffscreenCanvas<"u"&&new OffscreenCanvas(1,1).getContext("2d")!==null}catch{}function v(S,g){return m?new OffscreenCanvas(S,g):li("canvas")}function _(S,g,N,K){let j=1;if((S.width>K||S.height>K)&&(j=K/Math.max(S.width,S.height)),j<1||g===!0)if(typeof HTMLImageElement<"u"&&S instanceof HTMLImageElement||typeof HTMLCanvasElement<"u"&&S instanceof HTMLCanvasElement||typeof ImageBitmap<"u"&&S instanceof ImageBitmap){const J=g?Gr:Math.floor,dt=J(j*S.width),st=J(j*S.height);d===void 0&&(d=v(dt,st));const ct=N?v(dt,st):d;return ct.width=dt,ct.height=st,ct.getContext("2d").drawImage(S,0,0,dt,st),console.warn("THREE.WebGLRenderer: Texture has been resized from ("+S.width+"x"+S.height+") to ("+dt+"x"+st+")."),ct}else return"data"in S&&console.warn("THREE.WebGLRenderer: Image in DataTexture is too big ("+S.width+"x"+S.height+")."),S;return S}function p(S){return Ha(S.width)&&Ha(S.height)}function h(S){return s?!1:S.wrapS!==Ee||S.wrapT!==Ee||S.minFilter!==oe&&S.minFilter!==Re}function E(S,g){return S.generateMipmaps&&g&&S.minFilter!==oe&&S.minFilter!==Re}function T(S){i.generateMipmap(S)}function b(S,g,N,K,j=!1){if(s===!1)return g;if(S!==null){if(i[S]!==void 0)return i[S];console.warn("THREE.WebGLRenderer: Attempt to use non-existing WebGL internal format '"+S+"'")}let J=g;if(g===i.RED&&(N===i.FLOAT&&(J=i.R32F),N===i.HALF_FLOAT&&(J=i.R16F),N===i.UNSIGNED_BYTE&&(J=i.R8)),g===i.RED_INTEGER&&(N===i.UNSIGNED_BYTE&&(J=i.R8UI),N===i.UNSIGNED_SHORT&&(J=i.R16UI),N===i.UNSIGNED_INT&&(J=i.R32UI),N===i.BYTE&&(J=i.R8I),N===i.SHORT&&(J=i.R16I),N===i.INT&&(J=i.R32I)),g===i.RG&&(N===i.FLOAT&&(J=i.RG32F),N===i.HALF_FLOAT&&(J=i.RG16F),N===i.UNSIGNED_BYTE&&(J=i.RG8)),g===i.RGBA){const dt=j?Hi:Gt.getTransfer(K);N===i.FLOAT&&(J=i.RGBA32F),N===i.HALF_FLOAT&&(J=i.RGBA16F),N===i.UNSIGNED_BYTE&&(J=dt===$t?i.SRGB8_ALPHA8:i.RGBA8),N===i.UNSIGNED_SHORT_4_4_4_4&&(J=i.RGBA4),N===i.UNSIGNED_SHORT_5_5_5_1&&(J=i.RGB5_A1)}return(J===i.R16F||J===i.R32F||J===i.RG16F||J===i.RG32F||J===i.RGBA16F||J===i.RGBA32F)&&t.get("EXT_color_buffer_float"),J}function D(S,g,N){return E(S,N)===!0||S.isFramebufferTexture&&S.minFilter!==oe&&S.minFilter!==Re?Math.log2(Math.max(g.width,g.height))+1:S.mipmaps!==void 0&&S.mipmaps.length>0?S.mipmaps.length:S.isCompressedTexture&&Array.isArray(S.image)?g.mipmaps.length:1}function R(S){return S===oe||S===da||S===er?i.NEAREST:i.LINEAR}function w(S){const g=S.target;g.removeEventListener("dispose",w),y(g),g.isVideoTexture&&u.delete(g)}function Z(S){const g=S.target;g.removeEventListener("dispose",Z),H(g)}function y(S){const g=n.get(S);if(g.__webglInit===void 0)return;const N=S.source,K=f.get(N);if(K){const j=K[g.__cacheKey];j.usedTimes--,j.usedTimes===0&&M(S),Object.keys(K).length===0&&f.delete(N)}n.remove(S)}function M(S){const g=n.get(S);i.deleteTexture(g.__webglTexture);const N=S.source,K=f.get(N);delete K[g.__cacheKey],o.memory.textures--}function H(S){const g=S.texture,N=n.get(S),K=n.get(g);if(K.__webglTexture!==void 0&&(i.deleteTexture(K.__webglTexture),o.memory.textures--),S.depthTexture&&S.depthTexture.dispose(),S.isWebGLCubeRenderTarget)for(let j=0;j<6;j++){if(Array.isArray(N.__webglFramebuffer[j]))for(let J=0;J<N.__webglFramebuffer[j].length;J++)i.deleteFramebuffer(N.__webglFramebuffer[j][J]);else i.deleteFramebuffer(N.__webglFramebuffer[j]);N.__webglDepthbuffer&&i.deleteRenderbuffer(N.__webglDepthbuffer[j])}else{if(Array.isArray(N.__webglFramebuffer))for(let j=0;j<N.__webglFramebuffer.length;j++)i.deleteFramebuffer(N.__webglFramebuffer[j]);else i.deleteFramebuffer(N.__webglFramebuffer);if(N.__webglDepthbuffer&&i.deleteRenderbuffer(N.__webglDepthbuffer),N.__webglMultisampledFramebuffer&&i.deleteFramebuffer(N.__webglMultisampledFramebuffer),N.__webglColorRenderbuffer)for(let j=0;j<N.__webglColorRenderbuffer.length;j++)N.__webglColorRenderbuffer[j]&&i.deleteRenderbuffer(N.__webglColorRenderbuffer[j]);N.__webglDepthRenderbuffer&&i.deleteRenderbuffer(N.__webglDepthRenderbuffer)}if(S.isWebGLMultipleRenderTargets)for(let j=0,J=g.length;j<J;j++){const dt=n.get(g[j]);dt.__webglTexture&&(i.deleteTexture(dt.__webglTexture),o.memory.textures--),n.remove(g[j])}n.remove(g),n.remove(S)}let k=0;function it(){k=0}function C(){const S=k;return S>=r.maxTextures&&console.warn("THREE.WebGLTextures: Trying to use "+S+" texture units while this GPU supports only "+r.maxTextures),k+=1,S}function z(S){const g=[];return g.push(S.wrapS),g.push(S.wrapT),g.push(S.wrapR||0),g.push(S.magFilter),g.push(S.minFilter),g.push(S.anisotropy),g.push(S.internalFormat),g.push(S.format),g.push(S.type),g.push(S.generateMipmaps),g.push(S.premultiplyAlpha),g.push(S.flipY),g.push(S.unpackAlignment),g.push(S.colorSpace),g.join()}function V(S,g){const N=n.get(S);if(S.isVideoTexture&&jt(S),S.isRenderTargetTexture===!1&&S.version>0&&N.__version!==S.version){const K=S.image;if(K===null)console.warn("THREE.WebGLRenderer: Texture marked for update but no image data found.");else if(K.complete===!1)console.warn("THREE.WebGLRenderer: Texture marked for update but image is incomplete");else{ot(N,S,g);return}}e.bindTexture(i.TEXTURE_2D,N.__webglTexture,i.TEXTURE0+g)}function X(S,g){const N=n.get(S);if(S.version>0&&N.__version!==S.version){ot(N,S,g);return}e.bindTexture(i.TEXTURE_2D_ARRAY,N.__webglTexture,i.TEXTURE0+g)}function G(S,g){const N=n.get(S);if(S.version>0&&N.__version!==S.version){ot(N,S,g);return}e.bindTexture(i.TEXTURE_3D,N.__webglTexture,i.TEXTURE0+g)}function W(S,g){const N=n.get(S);if(S.version>0&&N.__version!==S.version){mt(N,S,g);return}e.bindTexture(i.TEXTURE_CUBE_MAP,N.__webglTexture,i.TEXTURE0+g)}const q={[zr]:i.REPEAT,[Ee]:i.CLAMP_TO_EDGE,[Br]:i.MIRRORED_REPEAT},Q={[oe]:i.NEAREST,[da]:i.NEAREST_MIPMAP_NEAREST,[er]:i.NEAREST_MIPMAP_LINEAR,[Re]:i.LINEAR,[Qo]:i.LINEAR_MIPMAP_NEAREST,[si]:i.LINEAR_MIPMAP_LINEAR},tt={[dl]:i.NEVER,[vl]:i.ALWAYS,[fl]:i.LESS,[Vs]:i.LEQUAL,[pl]:i.EQUAL,[_l]:i.GEQUAL,[ml]:i.GREATER,[gl]:i.NOTEQUAL};function B(S,g,N){if(N?(i.texParameteri(S,i.TEXTURE_WRAP_S,q[g.wrapS]),i.texParameteri(S,i.TEXTURE_WRAP_T,q[g.wrapT]),(S===i.TEXTURE_3D||S===i.TEXTURE_2D_ARRAY)&&i.texParameteri(S,i.TEXTURE_WRAP_R,q[g.wrapR]),i.texParameteri(S,i.TEXTURE_MAG_FILTER,Q[g.magFilter]),i.texParameteri(S,i.TEXTURE_MIN_FILTER,Q[g.minFilter])):(i.texParameteri(S,i.TEXTURE_WRAP_S,i.CLAMP_TO_EDGE),i.texParameteri(S,i.TEXTURE_WRAP_T,i.CLAMP_TO_EDGE),(S===i.TEXTURE_3D||S===i.TEXTURE_2D_ARRAY)&&i.texParameteri(S,i.TEXTURE_WRAP_R,i.CLAMP_TO_EDGE),(g.wrapS!==Ee||g.wrapT!==Ee)&&console.warn("THREE.WebGLRenderer: Texture is not power of two. Texture.wrapS and Texture.wrapT should be set to THREE.ClampToEdgeWrapping."),i.texParameteri(S,i.TEXTURE_MAG_FILTER,R(g.magFilter)),i.texParameteri(S,i.TEXTURE_MIN_FILTER,R(g.minFilter)),g.minFilter!==oe&&g.minFilter!==Re&&console.warn("THREE.WebGLRenderer: Texture is not power of two. Texture.minFilter should be set to THREE.NearestFilter or THREE.LinearFilter.")),g.compareFunction&&(i.texParameteri(S,i.TEXTURE_COMPARE_MODE,i.COMPARE_REF_TO_TEXTURE),i.texParameteri(S,i.TEXTURE_COMPARE_FUNC,tt[g.compareFunction])),t.has("EXT_texture_filter_anisotropic")===!0){const K=t.get("EXT_texture_filter_anisotropic");if(g.magFilter===oe||g.minFilter!==er&&g.minFilter!==si||g.type===$e&&t.has("OES_texture_float_linear")===!1||s===!1&&g.type===oi&&t.has("OES_texture_half_float_linear")===!1)return;(g.anisotropy>1||n.get(g).__currentAnisotropy)&&(i.texParameterf(S,K.TEXTURE_MAX_ANISOTROPY_EXT,Math.min(g.anisotropy,r.getMaxAnisotropy())),n.get(g).__currentAnisotropy=g.anisotropy)}}function Y(S,g){let N=!1;S.__webglInit===void 0&&(S.__webglInit=!0,g.addEventListener("dispose",w));const K=g.source;let j=f.get(K);j===void 0&&(j={},f.set(K,j));const J=z(g);if(J!==S.__cacheKey){j[J]===void 0&&(j[J]={texture:i.createTexture(),usedTimes:0},o.memory.textures++,N=!0),j[J].usedTimes++;const dt=j[S.__cacheKey];dt!==void 0&&(j[S.__cacheKey].usedTimes--,dt.usedTimes===0&&M(g)),S.__cacheKey=J,S.__webglTexture=j[J].texture}return N}function ot(S,g,N){let K=i.TEXTURE_2D;(g.isDataArrayTexture||g.isCompressedArrayTexture)&&(K=i.TEXTURE_2D_ARRAY),g.isData3DTexture&&(K=i.TEXTURE_3D);const j=Y(S,g),J=g.source;e.bindTexture(K,S.__webglTexture,i.TEXTURE0+N);const dt=n.get(J);if(J.version!==dt.__version||j===!0){e.activeTexture(i.TEXTURE0+N);const st=Gt.getPrimaries(Gt.workingColorSpace),ct=g.colorSpace===Pe?null:Gt.getPrimaries(g.colorSpace),St=g.colorSpace===Pe||st===ct?i.NONE:i.BROWSER_DEFAULT_WEBGL;i.pixelStorei(i.UNPACK_FLIP_Y_WEBGL,g.flipY),i.pixelStorei(i.UNPACK_PREMULTIPLY_ALPHA_WEBGL,g.premultiplyAlpha),i.pixelStorei(i.UNPACK_ALIGNMENT,g.unpackAlignment),i.pixelStorei(i.UNPACK_COLORSPACE_CONVERSION_WEBGL,St);const It=h(g)&&p(g.image)===!1;let $=_(g.image,It,!1,r.maxTextureSize);$=Ut(g,$);const Ht=p($)||s,zt=a.convert(g.format,g.colorSpace);let Et=a.convert(g.type),gt=b(g.internalFormat,zt,Et,g.colorSpace,g.isVideoTexture);B(K,g,Ht);let ut;const Lt=g.mipmaps,Vt=s&&g.isVideoTexture!==!0&&gt!==zs,Jt=dt.__version===void 0||j===!0,Ft=D(g,$,Ht);if(g.isDepthTexture)gt=i.DEPTH_COMPONENT,s?g.type===$e?gt=i.DEPTH_COMPONENT32F:g.type===sn?gt=i.DEPTH_COMPONENT24:g.type===Mn?gt=i.DEPTH24_STENCIL8:gt=i.DEPTH_COMPONENT16:g.type===$e&&console.error("WebGLRenderer: Floating point depth texture requires WebGL2."),g.format===En&&gt===i.DEPTH_COMPONENT&&g.type!==qr&&g.type!==sn&&(console.warn("THREE.WebGLRenderer: Use UnsignedShortType or UnsignedIntType for DepthFormat DepthTexture."),g.type=sn,Et=a.convert(g.type)),g.format===$n&&gt===i.DEPTH_COMPONENT&&(gt=i.DEPTH_STENCIL,g.type!==Mn&&(console.warn("THREE.WebGLRenderer: Use UnsignedInt248Type for DepthStencilFormat DepthTexture."),g.type=Mn,Et=a.convert(g.type))),Jt&&(Vt?e.texStorage2D(i.TEXTURE_2D,1,gt,$.width,$.height):e.texImage2D(i.TEXTURE_2D,0,gt,$.width,$.height,0,zt,Et,null));else if(g.isDataTexture)if(Lt.length>0&&Ht){Vt&&Jt&&e.texStorage2D(i.TEXTURE_2D,Ft,gt,Lt[0].width,Lt[0].height);for(let et=0,A=Lt.length;et<A;et++)ut=Lt[et],Vt?e.texSubImage2D(i.TEXTURE_2D,et,0,0,ut.width,ut.height,zt,Et,ut.data):e.texImage2D(i.TEXTURE_2D,et,gt,ut.width,ut.height,0,zt,Et,ut.data);g.generateMipmaps=!1}else Vt?(Jt&&e.texStorage2D(i.TEXTURE_2D,Ft,gt,$.width,$.height),e.texSubImage2D(i.TEXTURE_2D,0,0,0,$.width,$.height,zt,Et,$.data)):e.texImage2D(i.TEXTURE_2D,0,gt,$.width,$.height,0,zt,Et,$.data);else if(g.isCompressedTexture)if(g.isCompressedArrayTexture){Vt&&Jt&&e.texStorage3D(i.TEXTURE_2D_ARRAY,Ft,gt,Lt[0].width,Lt[0].height,$.depth);for(let et=0,A=Lt.length;et<A;et++)ut=Lt[et],g.format!==Ce?zt!==null?Vt?e.compressedTexSubImage3D(i.TEXTURE_2D_ARRAY,et,0,0,0,ut.width,ut.height,$.depth,zt,ut.data,0,0):e.compressedTexImage3D(i.TEXTURE_2D_ARRAY,et,gt,ut.width,ut.height,$.depth,0,ut.data,0,0):console.warn("THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()"):Vt?e.texSubImage3D(i.TEXTURE_2D_ARRAY,et,0,0,0,ut.width,ut.height,$.depth,zt,Et,ut.data):e.texImage3D(i.TEXTURE_2D_ARRAY,et,gt,ut.width,ut.height,$.depth,0,zt,Et,ut.data)}else{Vt&&Jt&&e.texStorage2D(i.TEXTURE_2D,Ft,gt,Lt[0].width,Lt[0].height);for(let et=0,A=Lt.length;et<A;et++)ut=Lt[et],g.format!==Ce?zt!==null?Vt?e.compressedTexSubImage2D(i.TEXTURE_2D,et,0,0,ut.width,ut.height,zt,ut.data):e.compressedTexImage2D(i.TEXTURE_2D,et,gt,ut.width,ut.height,0,ut.data):console.warn("THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .uploadTexture()"):Vt?e.texSubImage2D(i.TEXTURE_2D,et,0,0,ut.width,ut.height,zt,Et,ut.data):e.texImage2D(i.TEXTURE_2D,et,gt,ut.width,ut.height,0,zt,Et,ut.data)}else if(g.isDataArrayTexture)Vt?(Jt&&e.texStorage3D(i.TEXTURE_2D_ARRAY,Ft,gt,$.width,$.height,$.depth),e.texSubImage3D(i.TEXTURE_2D_ARRAY,0,0,0,0,$.width,$.height,$.depth,zt,Et,$.data)):e.texImage3D(i.TEXTURE_2D_ARRAY,0,gt,$.width,$.height,$.depth,0,zt,Et,$.data);else if(g.isData3DTexture)Vt?(Jt&&e.texStorage3D(i.TEXTURE_3D,Ft,gt,$.width,$.height,$.depth),e.texSubImage3D(i.TEXTURE_3D,0,0,0,0,$.width,$.height,$.depth,zt,Et,$.data)):e.texImage3D(i.TEXTURE_3D,0,gt,$.width,$.height,$.depth,0,zt,Et,$.data);else if(g.isFramebufferTexture){if(Jt)if(Vt)e.texStorage2D(i.TEXTURE_2D,Ft,gt,$.width,$.height);else{let et=$.width,A=$.height;for(let rt=0;rt<Ft;rt++)e.texImage2D(i.TEXTURE_2D,rt,gt,et,A,0,zt,Et,null),et>>=1,A>>=1}}else if(Lt.length>0&&Ht){Vt&&Jt&&e.texStorage2D(i.TEXTURE_2D,Ft,gt,Lt[0].width,Lt[0].height);for(let et=0,A=Lt.length;et<A;et++)ut=Lt[et],Vt?e.texSubImage2D(i.TEXTURE_2D,et,0,0,zt,Et,ut):e.texImage2D(i.TEXTURE_2D,et,gt,zt,Et,ut);g.generateMipmaps=!1}else Vt?(Jt&&e.texStorage2D(i.TEXTURE_2D,Ft,gt,$.width,$.height),e.texSubImage2D(i.TEXTURE_2D,0,0,0,zt,Et,$)):e.texImage2D(i.TEXTURE_2D,0,gt,zt,Et,$);E(g,Ht)&&T(K),dt.__version=J.version,g.onUpdate&&g.onUpdate(g)}S.__version=g.version}function mt(S,g,N){if(g.image.length!==6)return;const K=Y(S,g),j=g.source;e.bindTexture(i.TEXTURE_CUBE_MAP,S.__webglTexture,i.TEXTURE0+N);const J=n.get(j);if(j.version!==J.__version||K===!0){e.activeTexture(i.TEXTURE0+N);const dt=Gt.getPrimaries(Gt.workingColorSpace),st=g.colorSpace===Pe?null:Gt.getPrimaries(g.colorSpace),ct=g.colorSpace===Pe||dt===st?i.NONE:i.BROWSER_DEFAULT_WEBGL;i.pixelStorei(i.UNPACK_FLIP_Y_WEBGL,g.flipY),i.pixelStorei(i.UNPACK_PREMULTIPLY_ALPHA_WEBGL,g.premultiplyAlpha),i.pixelStorei(i.UNPACK_ALIGNMENT,g.unpackAlignment),i.pixelStorei(i.UNPACK_COLORSPACE_CONVERSION_WEBGL,ct);const St=g.isCompressedTexture||g.image[0].isCompressedTexture,It=g.image[0]&&g.image[0].isDataTexture,$=[];for(let et=0;et<6;et++)!St&&!It?$[et]=_(g.image[et],!1,!0,r.maxCubemapSize):$[et]=It?g.image[et].image:g.image[et],$[et]=Ut(g,$[et]);const Ht=$[0],zt=p(Ht)||s,Et=a.convert(g.format,g.colorSpace),gt=a.convert(g.type),ut=b(g.internalFormat,Et,gt,g.colorSpace),Lt=s&&g.isVideoTexture!==!0,Vt=J.__version===void 0||K===!0;let Jt=D(g,Ht,zt);B(i.TEXTURE_CUBE_MAP,g,zt);let Ft;if(St){Lt&&Vt&&e.texStorage2D(i.TEXTURE_CUBE_MAP,Jt,ut,Ht.width,Ht.height);for(let et=0;et<6;et++){Ft=$[et].mipmaps;for(let A=0;A<Ft.length;A++){const rt=Ft[A];g.format!==Ce?Et!==null?Lt?e.compressedTexSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+et,A,0,0,rt.width,rt.height,Et,rt.data):e.compressedTexImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+et,A,ut,rt.width,rt.height,0,rt.data):console.warn("THREE.WebGLRenderer: Attempt to load unsupported compressed texture format in .setTextureCube()"):Lt?e.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+et,A,0,0,rt.width,rt.height,Et,gt,rt.data):e.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+et,A,ut,rt.width,rt.height,0,Et,gt,rt.data)}}}else{Ft=g.mipmaps,Lt&&Vt&&(Ft.length>0&&Jt++,e.texStorage2D(i.TEXTURE_CUBE_MAP,Jt,ut,$[0].width,$[0].height));for(let et=0;et<6;et++)if(It){Lt?e.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+et,0,0,0,$[et].width,$[et].height,Et,gt,$[et].data):e.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+et,0,ut,$[et].width,$[et].height,0,Et,gt,$[et].data);for(let A=0;A<Ft.length;A++){const at=Ft[A].image[et].image;Lt?e.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+et,A+1,0,0,at.width,at.height,Et,gt,at.data):e.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+et,A+1,ut,at.width,at.height,0,Et,gt,at.data)}}else{Lt?e.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+et,0,0,0,Et,gt,$[et]):e.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+et,0,ut,Et,gt,$[et]);for(let A=0;A<Ft.length;A++){const rt=Ft[A];Lt?e.texSubImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+et,A+1,0,0,Et,gt,rt.image[et]):e.texImage2D(i.TEXTURE_CUBE_MAP_POSITIVE_X+et,A+1,ut,Et,gt,rt.image[et])}}}E(g,zt)&&T(i.TEXTURE_CUBE_MAP),J.__version=j.version,g.onUpdate&&g.onUpdate(g)}S.__version=g.version}function pt(S,g,N,K,j,J){const dt=a.convert(N.format,N.colorSpace),st=a.convert(N.type),ct=b(N.internalFormat,dt,st,N.colorSpace);if(!n.get(g).__hasExternalTextures){const It=Math.max(1,g.width>>J),$=Math.max(1,g.height>>J);j===i.TEXTURE_3D||j===i.TEXTURE_2D_ARRAY?e.texImage3D(j,J,ct,It,$,g.depth,0,dt,st,null):e.texImage2D(j,J,ct,It,$,0,dt,st,null)}e.bindFramebuffer(i.FRAMEBUFFER,S),ht(g)?l.framebufferTexture2DMultisampleEXT(i.FRAMEBUFFER,K,j,n.get(N).__webglTexture,0,bt(g)):(j===i.TEXTURE_2D||j>=i.TEXTURE_CUBE_MAP_POSITIVE_X&&j<=i.TEXTURE_CUBE_MAP_NEGATIVE_Z)&&i.framebufferTexture2D(i.FRAMEBUFFER,K,j,n.get(N).__webglTexture,J),e.bindFramebuffer(i.FRAMEBUFFER,null)}function wt(S,g,N){if(i.bindRenderbuffer(i.RENDERBUFFER,S),g.depthBuffer&&!g.stencilBuffer){let K=s===!0?i.DEPTH_COMPONENT24:i.DEPTH_COMPONENT16;if(N||ht(g)){const j=g.depthTexture;j&&j.isDepthTexture&&(j.type===$e?K=i.DEPTH_COMPONENT32F:j.type===sn&&(K=i.DEPTH_COMPONENT24));const J=bt(g);ht(g)?l.renderbufferStorageMultisampleEXT(i.RENDERBUFFER,J,K,g.width,g.height):i.renderbufferStorageMultisample(i.RENDERBUFFER,J,K,g.width,g.height)}else i.renderbufferStorage(i.RENDERBUFFER,K,g.width,g.height);i.framebufferRenderbuffer(i.FRAMEBUFFER,i.DEPTH_ATTACHMENT,i.RENDERBUFFER,S)}else if(g.depthBuffer&&g.stencilBuffer){const K=bt(g);N&&ht(g)===!1?i.renderbufferStorageMultisample(i.RENDERBUFFER,K,i.DEPTH24_STENCIL8,g.width,g.height):ht(g)?l.renderbufferStorageMultisampleEXT(i.RENDERBUFFER,K,i.DEPTH24_STENCIL8,g.width,g.height):i.renderbufferStorage(i.RENDERBUFFER,i.DEPTH_STENCIL,g.width,g.height),i.framebufferRenderbuffer(i.FRAMEBUFFER,i.DEPTH_STENCIL_ATTACHMENT,i.RENDERBUFFER,S)}else{const K=g.isWebGLMultipleRenderTargets===!0?g.texture:[g.texture];for(let j=0;j<K.length;j++){const J=K[j],dt=a.convert(J.format,J.colorSpace),st=a.convert(J.type),ct=b(J.internalFormat,dt,st,J.colorSpace),St=bt(g);N&&ht(g)===!1?i.renderbufferStorageMultisample(i.RENDERBUFFER,St,ct,g.width,g.height):ht(g)?l.renderbufferStorageMultisampleEXT(i.RENDERBUFFER,St,ct,g.width,g.height):i.renderbufferStorage(i.RENDERBUFFER,ct,g.width,g.height)}}i.bindRenderbuffer(i.RENDERBUFFER,null)}function Pt(S,g){if(g&&g.isWebGLCubeRenderTarget)throw new Error("Depth Texture with cube render targets is not supported");if(e.bindFramebuffer(i.FRAMEBUFFER,S),!(g.depthTexture&&g.depthTexture.isDepthTexture))throw new Error("renderTarget.depthTexture must be an instance of THREE.DepthTexture");(!n.get(g.depthTexture).__webglTexture||g.depthTexture.image.width!==g.width||g.depthTexture.image.height!==g.height)&&(g.depthTexture.image.width=g.width,g.depthTexture.image.height=g.height,g.depthTexture.needsUpdate=!0),V(g.depthTexture,0);const K=n.get(g.depthTexture).__webglTexture,j=bt(g);if(g.depthTexture.format===En)ht(g)?l.framebufferTexture2DMultisampleEXT(i.FRAMEBUFFER,i.DEPTH_ATTACHMENT,i.TEXTURE_2D,K,0,j):i.framebufferTexture2D(i.FRAMEBUFFER,i.DEPTH_ATTACHMENT,i.TEXTURE_2D,K,0);else if(g.depthTexture.format===$n)ht(g)?l.framebufferTexture2DMultisampleEXT(i.FRAMEBUFFER,i.DEPTH_STENCIL_ATTACHMENT,i.TEXTURE_2D,K,0,j):i.framebufferTexture2D(i.FRAMEBUFFER,i.DEPTH_STENCIL_ATTACHMENT,i.TEXTURE_2D,K,0);else throw new Error("Unknown depthTexture format")}function yt(S){const g=n.get(S),N=S.isWebGLCubeRenderTarget===!0;if(S.depthTexture&&!g.__autoAllocateDepthBuffer){if(N)throw new Error("target.depthTexture not supported in Cube render targets");Pt(g.__webglFramebuffer,S)}else if(N){g.__webglDepthbuffer=[];for(let K=0;K<6;K++)e.bindFramebuffer(i.FRAMEBUFFER,g.__webglFramebuffer[K]),g.__webglDepthbuffer[K]=i.createRenderbuffer(),wt(g.__webglDepthbuffer[K],S,!1)}else e.bindFramebuffer(i.FRAMEBUFFER,g.__webglFramebuffer),g.__webglDepthbuffer=i.createRenderbuffer(),wt(g.__webglDepthbuffer,S,!1);e.bindFramebuffer(i.FRAMEBUFFER,null)}function Bt(S,g,N){const K=n.get(S);g!==void 0&&pt(K.__webglFramebuffer,S,S.texture,i.COLOR_ATTACHMENT0,i.TEXTURE_2D,0),N!==void 0&&yt(S)}function U(S){const g=S.texture,N=n.get(S),K=n.get(g);S.addEventListener("dispose",Z),S.isWebGLMultipleRenderTargets!==!0&&(K.__webglTexture===void 0&&(K.__webglTexture=i.createTexture()),K.__version=g.version,o.memory.textures++);const j=S.isWebGLCubeRenderTarget===!0,J=S.isWebGLMultipleRenderTargets===!0,dt=p(S)||s;if(j){N.__webglFramebuffer=[];for(let st=0;st<6;st++)if(s&&g.mipmaps&&g.mipmaps.length>0){N.__webglFramebuffer[st]=[];for(let ct=0;ct<g.mipmaps.length;ct++)N.__webglFramebuffer[st][ct]=i.createFramebuffer()}else N.__webglFramebuffer[st]=i.createFramebuffer()}else{if(s&&g.mipmaps&&g.mipmaps.length>0){N.__webglFramebuffer=[];for(let st=0;st<g.mipmaps.length;st++)N.__webglFramebuffer[st]=i.createFramebuffer()}else N.__webglFramebuffer=i.createFramebuffer();if(J)if(r.drawBuffers){const st=S.texture;for(let ct=0,St=st.length;ct<St;ct++){const It=n.get(st[ct]);It.__webglTexture===void 0&&(It.__webglTexture=i.createTexture(),o.memory.textures++)}}else console.warn("THREE.WebGLRenderer: WebGLMultipleRenderTargets can only be used with WebGL2 or WEBGL_draw_buffers extension.");if(s&&S.samples>0&&ht(S)===!1){const st=J?g:[g];N.__webglMultisampledFramebuffer=i.createFramebuffer(),N.__webglColorRenderbuffer=[],e.bindFramebuffer(i.FRAMEBUFFER,N.__webglMultisampledFramebuffer);for(let ct=0;ct<st.length;ct++){const St=st[ct];N.__webglColorRenderbuffer[ct]=i.createRenderbuffer(),i.bindRenderbuffer(i.RENDERBUFFER,N.__webglColorRenderbuffer[ct]);const It=a.convert(St.format,St.colorSpace),$=a.convert(St.type),Ht=b(St.internalFormat,It,$,St.colorSpace,S.isXRRenderTarget===!0),zt=bt(S);i.renderbufferStorageMultisample(i.RENDERBUFFER,zt,Ht,S.width,S.height),i.framebufferRenderbuffer(i.FRAMEBUFFER,i.COLOR_ATTACHMENT0+ct,i.RENDERBUFFER,N.__webglColorRenderbuffer[ct])}i.bindRenderbuffer(i.RENDERBUFFER,null),S.depthBuffer&&(N.__webglDepthRenderbuffer=i.createRenderbuffer(),wt(N.__webglDepthRenderbuffer,S,!0)),e.bindFramebuffer(i.FRAMEBUFFER,null)}}if(j){e.bindTexture(i.TEXTURE_CUBE_MAP,K.__webglTexture),B(i.TEXTURE_CUBE_MAP,g,dt);for(let st=0;st<6;st++)if(s&&g.mipmaps&&g.mipmaps.length>0)for(let ct=0;ct<g.mipmaps.length;ct++)pt(N.__webglFramebuffer[st][ct],S,g,i.COLOR_ATTACHMENT0,i.TEXTURE_CUBE_MAP_POSITIVE_X+st,ct);else pt(N.__webglFramebuffer[st],S,g,i.COLOR_ATTACHMENT0,i.TEXTURE_CUBE_MAP_POSITIVE_X+st,0);E(g,dt)&&T(i.TEXTURE_CUBE_MAP),e.unbindTexture()}else if(J){const st=S.texture;for(let ct=0,St=st.length;ct<St;ct++){const It=st[ct],$=n.get(It);e.bindTexture(i.TEXTURE_2D,$.__webglTexture),B(i.TEXTURE_2D,It,dt),pt(N.__webglFramebuffer,S,It,i.COLOR_ATTACHMENT0+ct,i.TEXTURE_2D,0),E(It,dt)&&T(i.TEXTURE_2D)}e.unbindTexture()}else{let st=i.TEXTURE_2D;if((S.isWebGL3DRenderTarget||S.isWebGLArrayRenderTarget)&&(s?st=S.isWebGL3DRenderTarget?i.TEXTURE_3D:i.TEXTURE_2D_ARRAY:console.error("THREE.WebGLTextures: THREE.Data3DTexture and THREE.DataArrayTexture only supported with WebGL2.")),e.bindTexture(st,K.__webglTexture),B(st,g,dt),s&&g.mipmaps&&g.mipmaps.length>0)for(let ct=0;ct<g.mipmaps.length;ct++)pt(N.__webglFramebuffer[ct],S,g,i.COLOR_ATTACHMENT0,st,ct);else pt(N.__webglFramebuffer,S,g,i.COLOR_ATTACHMENT0,st,0);E(g,dt)&&T(st),e.unbindTexture()}S.depthBuffer&&yt(S)}function fe(S){const g=p(S)||s,N=S.isWebGLMultipleRenderTargets===!0?S.texture:[S.texture];for(let K=0,j=N.length;K<j;K++){const J=N[K];if(E(J,g)){const dt=S.isWebGLCubeRenderTarget?i.TEXTURE_CUBE_MAP:i.TEXTURE_2D,st=n.get(J).__webglTexture;e.bindTexture(dt,st),T(dt),e.unbindTexture()}}}function _t(S){if(s&&S.samples>0&&ht(S)===!1){const g=S.isWebGLMultipleRenderTargets?S.texture:[S.texture],N=S.width,K=S.height;let j=i.COLOR_BUFFER_BIT;const J=[],dt=S.stencilBuffer?i.DEPTH_STENCIL_ATTACHMENT:i.DEPTH_ATTACHMENT,st=n.get(S),ct=S.isWebGLMultipleRenderTargets===!0;if(ct)for(let St=0;St<g.length;St++)e.bindFramebuffer(i.FRAMEBUFFER,st.__webglMultisampledFramebuffer),i.framebufferRenderbuffer(i.FRAMEBUFFER,i.COLOR_ATTACHMENT0+St,i.RENDERBUFFER,null),e.bindFramebuffer(i.FRAMEBUFFER,st.__webglFramebuffer),i.framebufferTexture2D(i.DRAW_FRAMEBUFFER,i.COLOR_ATTACHMENT0+St,i.TEXTURE_2D,null,0);e.bindFramebuffer(i.READ_FRAMEBUFFER,st.__webglMultisampledFramebuffer),e.bindFramebuffer(i.DRAW_FRAMEBUFFER,st.__webglFramebuffer);for(let St=0;St<g.length;St++){J.push(i.COLOR_ATTACHMENT0+St),S.depthBuffer&&J.push(dt);const It=st.__ignoreDepthValues!==void 0?st.__ignoreDepthValues:!1;if(It===!1&&(S.depthBuffer&&(j|=i.DEPTH_BUFFER_BIT),S.stencilBuffer&&(j|=i.STENCIL_BUFFER_BIT)),ct&&i.framebufferRenderbuffer(i.READ_FRAMEBUFFER,i.COLOR_ATTACHMENT0,i.RENDERBUFFER,st.__webglColorRenderbuffer[St]),It===!0&&(i.invalidateFramebuffer(i.READ_FRAMEBUFFER,[dt]),i.invalidateFramebuffer(i.DRAW_FRAMEBUFFER,[dt])),ct){const $=n.get(g[St]).__webglTexture;i.framebufferTexture2D(i.DRAW_FRAMEBUFFER,i.COLOR_ATTACHMENT0,i.TEXTURE_2D,$,0)}i.blitFramebuffer(0,0,N,K,0,0,N,K,j,i.NEAREST),c&&i.invalidateFramebuffer(i.READ_FRAMEBUFFER,J)}if(e.bindFramebuffer(i.READ_FRAMEBUFFER,null),e.bindFramebuffer(i.DRAW_FRAMEBUFFER,null),ct)for(let St=0;St<g.length;St++){e.bindFramebuffer(i.FRAMEBUFFER,st.__webglMultisampledFramebuffer),i.framebufferRenderbuffer(i.FRAMEBUFFER,i.COLOR_ATTACHMENT0+St,i.RENDERBUFFER,st.__webglColorRenderbuffer[St]);const It=n.get(g[St]).__webglTexture;e.bindFramebuffer(i.FRAMEBUFFER,st.__webglFramebuffer),i.framebufferTexture2D(i.DRAW_FRAMEBUFFER,i.COLOR_ATTACHMENT0+St,i.TEXTURE_2D,It,0)}e.bindFramebuffer(i.DRAW_FRAMEBUFFER,st.__webglMultisampledFramebuffer)}}function bt(S){return Math.min(r.maxSamples,S.samples)}function ht(S){const g=n.get(S);return s&&S.samples>0&&t.has("WEBGL_multisampled_render_to_texture")===!0&&g.__useRenderToTexture!==!1}function jt(S){const g=o.render.frame;u.get(S)!==g&&(u.set(S,g),S.update())}function Ut(S,g){const N=S.colorSpace,K=S.format,j=S.type;return S.isCompressedTexture===!0||S.isVideoTexture===!0||S.format===Vr||N!==Je&&N!==Pe&&(Gt.getTransfer(N)===$t?s===!1?t.has("EXT_sRGB")===!0&&K===Ce?(S.format=Vr,S.minFilter=Re,S.generateMipmaps=!1):g=Gs.sRGBToLinear(g):(K!==Ce||j!==cn)&&console.warn("THREE.WebGLTextures: sRGB encoded textures have to use RGBAFormat and UnsignedByteType."):console.error("THREE.WebGLTextures: Unsupported texture color space:",N)),g}this.allocateTextureUnit=C,this.resetTextureUnits=it,this.setTexture2D=V,this.setTexture2DArray=X,this.setTexture3D=G,this.setTextureCube=W,this.rebindTextures=Bt,this.setupRenderTarget=U,this.updateRenderTargetMipmap=fe,this.updateMultisampleRenderTarget=_t,this.setupDepthRenderbuffer=yt,this.setupFrameBufferTexture=pt,this.useMultisampledRTT=ht}function yf(i,t,e){const n=e.isWebGL2;function r(a,o=Pe){let s;const l=Gt.getTransfer(o);if(a===cn)return i.UNSIGNED_BYTE;if(a===Us)return i.UNSIGNED_SHORT_4_4_4_4;if(a===Is)return i.UNSIGNED_SHORT_5_5_5_1;if(a===tl)return i.BYTE;if(a===el)return i.SHORT;if(a===qr)return i.UNSIGNED_SHORT;if(a===Ds)return i.INT;if(a===sn)return i.UNSIGNED_INT;if(a===$e)return i.FLOAT;if(a===oi)return n?i.HALF_FLOAT:(s=t.get("OES_texture_half_float"),s!==null?s.HALF_FLOAT_OES:null);if(a===nl)return i.ALPHA;if(a===Ce)return i.RGBA;if(a===il)return i.LUMINANCE;if(a===rl)return i.LUMINANCE_ALPHA;if(a===En)return i.DEPTH_COMPONENT;if(a===$n)return i.DEPTH_STENCIL;if(a===Vr)return s=t.get("EXT_sRGB"),s!==null?s.SRGB_ALPHA_EXT:null;if(a===al)return i.RED;if(a===Ns)return i.RED_INTEGER;if(a===sl)return i.RG;if(a===Fs)return i.RG_INTEGER;if(a===Os)return i.RGBA_INTEGER;if(a===nr||a===ir||a===rr||a===ar)if(l===$t)if(s=t.get("WEBGL_compressed_texture_s3tc_srgb"),s!==null){if(a===nr)return s.COMPRESSED_SRGB_S3TC_DXT1_EXT;if(a===ir)return s.COMPRESSED_SRGB_ALPHA_S3TC_DXT1_EXT;if(a===rr)return s.COMPRESSED_SRGB_ALPHA_S3TC_DXT3_EXT;if(a===ar)return s.COMPRESSED_SRGB_ALPHA_S3TC_DXT5_EXT}else return null;else if(s=t.get("WEBGL_compressed_texture_s3tc"),s!==null){if(a===nr)return s.COMPRESSED_RGB_S3TC_DXT1_EXT;if(a===ir)return s.COMPRESSED_RGBA_S3TC_DXT1_EXT;if(a===rr)return s.COMPRESSED_RGBA_S3TC_DXT3_EXT;if(a===ar)return s.COMPRESSED_RGBA_S3TC_DXT5_EXT}else return null;if(a===fa||a===pa||a===ma||a===ga)if(s=t.get("WEBGL_compressed_texture_pvrtc"),s!==null){if(a===fa)return s.COMPRESSED_RGB_PVRTC_4BPPV1_IMG;if(a===pa)return s.COMPRESSED_RGB_PVRTC_2BPPV1_IMG;if(a===ma)return s.COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;if(a===ga)return s.COMPRESSED_RGBA_PVRTC_2BPPV1_IMG}else return null;if(a===zs)return s=t.get("WEBGL_compressed_texture_etc1"),s!==null?s.COMPRESSED_RGB_ETC1_WEBGL:null;if(a===_a||a===va)if(s=t.get("WEBGL_compressed_texture_etc"),s!==null){if(a===_a)return l===$t?s.COMPRESSED_SRGB8_ETC2:s.COMPRESSED_RGB8_ETC2;if(a===va)return l===$t?s.COMPRESSED_SRGB8_ALPHA8_ETC2_EAC:s.COMPRESSED_RGBA8_ETC2_EAC}else return null;if(a===xa||a===Sa||a===ya||a===Ta||a===Ma||a===Ea||a===ba||a===Aa||a===wa||a===Ra||a===Ca||a===Pa||a===La||a===Da)if(s=t.get("WEBGL_compressed_texture_astc"),s!==null){if(a===xa)return l===$t?s.COMPRESSED_SRGB8_ALPHA8_ASTC_4x4_KHR:s.COMPRESSED_RGBA_ASTC_4x4_KHR;if(a===Sa)return l===$t?s.COMPRESSED_SRGB8_ALPHA8_ASTC_5x4_KHR:s.COMPRESSED_RGBA_ASTC_5x4_KHR;if(a===ya)return l===$t?s.COMPRESSED_SRGB8_ALPHA8_ASTC_5x5_KHR:s.COMPRESSED_RGBA_ASTC_5x5_KHR;if(a===Ta)return l===$t?s.COMPRESSED_SRGB8_ALPHA8_ASTC_6x5_KHR:s.COMPRESSED_RGBA_ASTC_6x5_KHR;if(a===Ma)return l===$t?s.COMPRESSED_SRGB8_ALPHA8_ASTC_6x6_KHR:s.COMPRESSED_RGBA_ASTC_6x6_KHR;if(a===Ea)return l===$t?s.COMPRESSED_SRGB8_ALPHA8_ASTC_8x5_KHR:s.COMPRESSED_RGBA_ASTC_8x5_KHR;if(a===ba)return l===$t?s.COMPRESSED_SRGB8_ALPHA8_ASTC_8x6_KHR:s.COMPRESSED_RGBA_ASTC_8x6_KHR;if(a===Aa)return l===$t?s.COMPRESSED_SRGB8_ALPHA8_ASTC_8x8_KHR:s.COMPRESSED_RGBA_ASTC_8x8_KHR;if(a===wa)return l===$t?s.COMPRESSED_SRGB8_ALPHA8_ASTC_10x5_KHR:s.COMPRESSED_RGBA_ASTC_10x5_KHR;if(a===Ra)return l===$t?s.COMPRESSED_SRGB8_ALPHA8_ASTC_10x6_KHR:s.COMPRESSED_RGBA_ASTC_10x6_KHR;if(a===Ca)return l===$t?s.COMPRESSED_SRGB8_ALPHA8_ASTC_10x8_KHR:s.COMPRESSED_RGBA_ASTC_10x8_KHR;if(a===Pa)return l===$t?s.COMPRESSED_SRGB8_ALPHA8_ASTC_10x10_KHR:s.COMPRESSED_RGBA_ASTC_10x10_KHR;if(a===La)return l===$t?s.COMPRESSED_SRGB8_ALPHA8_ASTC_12x10_KHR:s.COMPRESSED_RGBA_ASTC_12x10_KHR;if(a===Da)return l===$t?s.COMPRESSED_SRGB8_ALPHA8_ASTC_12x12_KHR:s.COMPRESSED_RGBA_ASTC_12x12_KHR}else return null;if(a===sr||a===Ua||a===Ia)if(s=t.get("EXT_texture_compression_bptc"),s!==null){if(a===sr)return l===$t?s.COMPRESSED_SRGB_ALPHA_BPTC_UNORM_EXT:s.COMPRESSED_RGBA_BPTC_UNORM_EXT;if(a===Ua)return s.COMPRESSED_RGB_BPTC_SIGNED_FLOAT_EXT;if(a===Ia)return s.COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT_EXT}else return null;if(a===ol||a===Na||a===Fa||a===Oa)if(s=t.get("EXT_texture_compression_rgtc"),s!==null){if(a===sr)return s.COMPRESSED_RED_RGTC1_EXT;if(a===Na)return s.COMPRESSED_SIGNED_RED_RGTC1_EXT;if(a===Fa)return s.COMPRESSED_RED_GREEN_RGTC2_EXT;if(a===Oa)return s.COMPRESSED_SIGNED_RED_GREEN_RGTC2_EXT}else return null;return a===Mn?n?i.UNSIGNED_INT_24_8:(s=t.get("WEBGL_depth_texture"),s!==null?s.UNSIGNED_INT_24_8_WEBGL:null):i[a]!==void 0?i[a]:null}return{convert:r}}class Tf extends Ne{constructor(t=[]){super(),this.isArrayCamera=!0,this.cameras=t}}class zi extends be{constructor(){super(),this.isGroup=!0,this.type="Group"}}const Mf={type:"move"};class Lr{constructor(){this._targetRay=null,this._grip=null,this._hand=null}getHandSpace(){return this._hand===null&&(this._hand=new zi,this._hand.matrixAutoUpdate=!1,this._hand.visible=!1,this._hand.joints={},this._hand.inputState={pinching:!1}),this._hand}getTargetRaySpace(){return this._targetRay===null&&(this._targetRay=new zi,this._targetRay.matrixAutoUpdate=!1,this._targetRay.visible=!1,this._targetRay.hasLinearVelocity=!1,this._targetRay.linearVelocity=new L,this._targetRay.hasAngularVelocity=!1,this._targetRay.angularVelocity=new L),this._targetRay}getGripSpace(){return this._grip===null&&(this._grip=new zi,this._grip.matrixAutoUpdate=!1,this._grip.visible=!1,this._grip.hasLinearVelocity=!1,this._grip.linearVelocity=new L,this._grip.hasAngularVelocity=!1,this._grip.angularVelocity=new L),this._grip}dispatchEvent(t){return this._targetRay!==null&&this._targetRay.dispatchEvent(t),this._grip!==null&&this._grip.dispatchEvent(t),this._hand!==null&&this._hand.dispatchEvent(t),this}connect(t){if(t&&t.hand){const e=this._hand;if(e)for(const n of t.hand.values())this._getHandJoint(e,n)}return this.dispatchEvent({type:"connected",data:t}),this}disconnect(t){return this.dispatchEvent({type:"disconnected",data:t}),this._targetRay!==null&&(this._targetRay.visible=!1),this._grip!==null&&(this._grip.visible=!1),this._hand!==null&&(this._hand.visible=!1),this}update(t,e,n){let r=null,a=null,o=null;const s=this._targetRay,l=this._grip,c=this._hand;if(t&&e.session.visibilityState!=="visible-blurred"){if(c&&t.hand){o=!0;for(const _ of t.hand.values()){const p=e.getJointPose(_,n),h=this._getHandJoint(c,_);p!==null&&(h.matrix.fromArray(p.transform.matrix),h.matrix.decompose(h.position,h.rotation,h.scale),h.matrixWorldNeedsUpdate=!0,h.jointRadius=p.radius),h.visible=p!==null}const u=c.joints["index-finger-tip"],d=c.joints["thumb-tip"],f=u.position.distanceTo(d.position),m=.02,v=.005;c.inputState.pinching&&f>m+v?(c.inputState.pinching=!1,this.dispatchEvent({type:"pinchend",handedness:t.handedness,target:this})):!c.inputState.pinching&&f<=m-v&&(c.inputState.pinching=!0,this.dispatchEvent({type:"pinchstart",handedness:t.handedness,target:this}))}else l!==null&&t.gripSpace&&(a=e.getPose(t.gripSpace,n),a!==null&&(l.matrix.fromArray(a.transform.matrix),l.matrix.decompose(l.position,l.rotation,l.scale),l.matrixWorldNeedsUpdate=!0,a.linearVelocity?(l.hasLinearVelocity=!0,l.linearVelocity.copy(a.linearVelocity)):l.hasLinearVelocity=!1,a.angularVelocity?(l.hasAngularVelocity=!0,l.angularVelocity.copy(a.angularVelocity)):l.hasAngularVelocity=!1));s!==null&&(r=e.getPose(t.targetRaySpace,n),r===null&&a!==null&&(r=a),r!==null&&(s.matrix.fromArray(r.transform.matrix),s.matrix.decompose(s.position,s.rotation,s.scale),s.matrixWorldNeedsUpdate=!0,r.linearVelocity?(s.hasLinearVelocity=!0,s.linearVelocity.copy(r.linearVelocity)):s.hasLinearVelocity=!1,r.angularVelocity?(s.hasAngularVelocity=!0,s.angularVelocity.copy(r.angularVelocity)):s.hasAngularVelocity=!1,this.dispatchEvent(Mf)))}return s!==null&&(s.visible=r!==null),l!==null&&(l.visible=a!==null),c!==null&&(c.visible=o!==null),this}_getHandJoint(t,e){if(t.joints[e.jointName]===void 0){const n=new zi;n.matrixAutoUpdate=!1,n.visible=!1,t.joints[e.jointName]=n,t.add(n)}return t.joints[e.jointName]}}class Ef extends Zn{constructor(t,e){super();const n=this;let r=null,a=1,o=null,s="local-floor",l=1,c=null,u=null,d=null,f=null,m=null,v=null;const _=e.getContextAttributes();let p=null,h=null;const E=[],T=[],b=new Wt;let D=null;const R=new Ne;R.layers.enable(1),R.viewport=new ce;const w=new Ne;w.layers.enable(2),w.viewport=new ce;const Z=[R,w],y=new Tf;y.layers.enable(1),y.layers.enable(2);let M=null,H=null;this.cameraAutoUpdate=!0,this.enabled=!1,this.isPresenting=!1,this.getController=function(B){let Y=E[B];return Y===void 0&&(Y=new Lr,E[B]=Y),Y.getTargetRaySpace()},this.getControllerGrip=function(B){let Y=E[B];return Y===void 0&&(Y=new Lr,E[B]=Y),Y.getGripSpace()},this.getHand=function(B){let Y=E[B];return Y===void 0&&(Y=new Lr,E[B]=Y),Y.getHandSpace()};function k(B){const Y=T.indexOf(B.inputSource);if(Y===-1)return;const ot=E[Y];ot!==void 0&&(ot.update(B.inputSource,B.frame,c||o),ot.dispatchEvent({type:B.type,data:B.inputSource}))}function it(){r.removeEventListener("select",k),r.removeEventListener("selectstart",k),r.removeEventListener("selectend",k),r.removeEventListener("squeeze",k),r.removeEventListener("squeezestart",k),r.removeEventListener("squeezeend",k),r.removeEventListener("end",it),r.removeEventListener("inputsourceschange",C);for(let B=0;B<E.length;B++){const Y=T[B];Y!==null&&(T[B]=null,E[B].disconnect(Y))}M=null,H=null,t.setRenderTarget(p),m=null,f=null,d=null,r=null,h=null,tt.stop(),n.isPresenting=!1,t.setPixelRatio(D),t.setSize(b.width,b.height,!1),n.dispatchEvent({type:"sessionend"})}this.setFramebufferScaleFactor=function(B){a=B,n.isPresenting===!0&&console.warn("THREE.WebXRManager: Cannot change framebuffer scale while presenting.")},this.setReferenceSpaceType=function(B){s=B,n.isPresenting===!0&&console.warn("THREE.WebXRManager: Cannot change reference space type while presenting.")},this.getReferenceSpace=function(){return c||o},this.setReferenceSpace=function(B){c=B},this.getBaseLayer=function(){return f!==null?f:m},this.getBinding=function(){return d},this.getFrame=function(){return v},this.getSession=function(){return r},this.setSession=async function(B){if(r=B,r!==null){if(p=t.getRenderTarget(),r.addEventListener("select",k),r.addEventListener("selectstart",k),r.addEventListener("selectend",k),r.addEventListener("squeeze",k),r.addEventListener("squeezestart",k),r.addEventListener("squeezeend",k),r.addEventListener("end",it),r.addEventListener("inputsourceschange",C),_.xrCompatible!==!0&&await e.makeXRCompatible(),D=t.getPixelRatio(),t.getSize(b),r.renderState.layers===void 0||t.capabilities.isWebGL2===!1){const Y={antialias:r.renderState.layers===void 0?_.antialias:!0,alpha:!0,depth:_.depth,stencil:_.stencil,framebufferScaleFactor:a};m=new XRWebGLLayer(r,e,Y),r.updateRenderState({baseLayer:m}),t.setPixelRatio(1),t.setSize(m.framebufferWidth,m.framebufferHeight,!1),h=new Qe(m.framebufferWidth,m.framebufferHeight,{format:Ce,type:cn,colorSpace:t.outputColorSpace,stencilBuffer:_.stencil})}else{let Y=null,ot=null,mt=null;_.depth&&(mt=_.stencil?e.DEPTH24_STENCIL8:e.DEPTH_COMPONENT24,Y=_.stencil?$n:En,ot=_.stencil?Mn:sn);const pt={colorFormat:e.RGBA8,depthFormat:mt,scaleFactor:a};d=new XRWebGLBinding(r,e),f=d.createProjectionLayer(pt),r.updateRenderState({layers:[f]}),t.setPixelRatio(1),t.setSize(f.textureWidth,f.textureHeight,!1),h=new Qe(f.textureWidth,f.textureHeight,{format:Ce,type:cn,depthTexture:new no(f.textureWidth,f.textureHeight,ot,void 0,void 0,void 0,void 0,void 0,void 0,Y),stencilBuffer:_.stencil,colorSpace:t.outputColorSpace,samples:_.antialias?4:0});const wt=t.properties.get(h);wt.__ignoreDepthValues=f.ignoreDepthValues}h.isXRRenderTarget=!0,this.setFoveation(l),c=null,o=await r.requestReferenceSpace(s),tt.setContext(r),tt.start(),n.isPresenting=!0,n.dispatchEvent({type:"sessionstart"})}},this.getEnvironmentBlendMode=function(){if(r!==null)return r.environmentBlendMode};function C(B){for(let Y=0;Y<B.removed.length;Y++){const ot=B.removed[Y],mt=T.indexOf(ot);mt>=0&&(T[mt]=null,E[mt].disconnect(ot))}for(let Y=0;Y<B.added.length;Y++){const ot=B.added[Y];let mt=T.indexOf(ot);if(mt===-1){for(let wt=0;wt<E.length;wt++)if(wt>=T.length){T.push(ot),mt=wt;break}else if(T[wt]===null){T[wt]=ot,mt=wt;break}if(mt===-1)break}const pt=E[mt];pt&&pt.connect(ot)}}const z=new L,V=new L;function X(B,Y,ot){z.setFromMatrixPosition(Y.matrixWorld),V.setFromMatrixPosition(ot.matrixWorld);const mt=z.distanceTo(V),pt=Y.projectionMatrix.elements,wt=ot.projectionMatrix.elements,Pt=pt[14]/(pt[10]-1),yt=pt[14]/(pt[10]+1),Bt=(pt[9]+1)/pt[5],U=(pt[9]-1)/pt[5],fe=(pt[8]-1)/pt[0],_t=(wt[8]+1)/wt[0],bt=Pt*fe,ht=Pt*_t,jt=mt/(-fe+_t),Ut=jt*-fe;Y.matrixWorld.decompose(B.position,B.quaternion,B.scale),B.translateX(Ut),B.translateZ(jt),B.matrixWorld.compose(B.position,B.quaternion,B.scale),B.matrixWorldInverse.copy(B.matrixWorld).invert();const S=Pt+jt,g=yt+jt,N=bt-Ut,K=ht+(mt-Ut),j=Bt*yt/g*S,J=U*yt/g*S;B.projectionMatrix.makePerspective(N,K,j,J,S,g),B.projectionMatrixInverse.copy(B.projectionMatrix).invert()}function G(B,Y){Y===null?B.matrixWorld.copy(B.matrix):B.matrixWorld.multiplyMatrices(Y.matrixWorld,B.matrix),B.matrixWorldInverse.copy(B.matrixWorld).invert()}this.updateCamera=function(B){if(r===null)return;y.near=w.near=R.near=B.near,y.far=w.far=R.far=B.far,(M!==y.near||H!==y.far)&&(r.updateRenderState({depthNear:y.near,depthFar:y.far}),M=y.near,H=y.far);const Y=B.parent,ot=y.cameras;G(y,Y);for(let mt=0;mt<ot.length;mt++)G(ot[mt],Y);ot.length===2?X(y,R,w):y.projectionMatrix.copy(R.projectionMatrix),W(B,y,Y)};function W(B,Y,ot){ot===null?B.matrix.copy(Y.matrixWorld):(B.matrix.copy(ot.matrixWorld),B.matrix.invert(),B.matrix.multiply(Y.matrixWorld)),B.matrix.decompose(B.position,B.quaternion,B.scale),B.updateMatrixWorld(!0),B.projectionMatrix.copy(Y.projectionMatrix),B.projectionMatrixInverse.copy(Y.projectionMatrixInverse),B.isPerspectiveCamera&&(B.fov=Hr*2*Math.atan(1/B.projectionMatrix.elements[5]),B.zoom=1)}this.getCamera=function(){return y},this.getFoveation=function(){if(!(f===null&&m===null))return l},this.setFoveation=function(B){l=B,f!==null&&(f.fixedFoveation=B),m!==null&&m.fixedFoveation!==void 0&&(m.fixedFoveation=B)};let q=null;function Q(B,Y){if(u=Y.getViewerPose(c||o),v=Y,u!==null){const ot=u.views;m!==null&&(t.setRenderTargetFramebuffer(h,m.framebuffer),t.setRenderTarget(h));let mt=!1;ot.length!==y.cameras.length&&(y.cameras.length=0,mt=!0);for(let pt=0;pt<ot.length;pt++){const wt=ot[pt];let Pt=null;if(m!==null)Pt=m.getViewport(wt);else{const Bt=d.getViewSubImage(f,wt);Pt=Bt.viewport,pt===0&&(t.setRenderTargetTextures(h,Bt.colorTexture,f.ignoreDepthValues?void 0:Bt.depthStencilTexture),t.setRenderTarget(h))}let yt=Z[pt];yt===void 0&&(yt=new Ne,yt.layers.enable(pt),yt.viewport=new ce,Z[pt]=yt),yt.matrix.fromArray(wt.transform.matrix),yt.matrix.decompose(yt.position,yt.quaternion,yt.scale),yt.projectionMatrix.fromArray(wt.projectionMatrix),yt.projectionMatrixInverse.copy(yt.projectionMatrix).invert(),yt.viewport.set(Pt.x,Pt.y,Pt.width,Pt.height),pt===0&&(y.matrix.copy(yt.matrix),y.matrix.decompose(y.position,y.quaternion,y.scale)),mt===!0&&y.cameras.push(yt)}}for(let ot=0;ot<E.length;ot++){const mt=T[ot],pt=E[ot];mt!==null&&pt!==void 0&&pt.update(mt,Y,c||o)}q&&q(B,Y),Y.detectedPlanes&&n.dispatchEvent({type:"planesdetected",data:Y}),v=null}const tt=new to;tt.setAnimationLoop(Q),this.setAnimationLoop=function(B){q=B},this.dispose=function(){}}}function bf(i,t){function e(p,h){p.matrixAutoUpdate===!0&&p.updateMatrix(),h.value.copy(p.matrix)}function n(p,h){h.color.getRGB(p.fogColor.value,Zs(i)),h.isFog?(p.fogNear.value=h.near,p.fogFar.value=h.far):h.isFogExp2&&(p.fogDensity.value=h.density)}function r(p,h,E,T,b){h.isMeshBasicMaterial||h.isMeshLambertMaterial?a(p,h):h.isMeshToonMaterial?(a(p,h),d(p,h)):h.isMeshPhongMaterial?(a(p,h),u(p,h)):h.isMeshStandardMaterial?(a(p,h),f(p,h),h.isMeshPhysicalMaterial&&m(p,h,b)):h.isMeshMatcapMaterial?(a(p,h),v(p,h)):h.isMeshDepthMaterial?a(p,h):h.isMeshDistanceMaterial?(a(p,h),_(p,h)):h.isMeshNormalMaterial?a(p,h):h.isLineBasicMaterial?(o(p,h),h.isLineDashedMaterial&&s(p,h)):h.isPointsMaterial?l(p,h,E,T):h.isSpriteMaterial?c(p,h):h.isShadowMaterial?(p.color.value.copy(h.color),p.opacity.value=h.opacity):h.isShaderMaterial&&(h.uniformsNeedUpdate=!1)}function a(p,h){p.opacity.value=h.opacity,h.color&&p.diffuse.value.copy(h.color),h.emissive&&p.emissive.value.copy(h.emissive).multiplyScalar(h.emissiveIntensity),h.map&&(p.map.value=h.map,e(h.map,p.mapTransform)),h.alphaMap&&(p.alphaMap.value=h.alphaMap,e(h.alphaMap,p.alphaMapTransform)),h.bumpMap&&(p.bumpMap.value=h.bumpMap,e(h.bumpMap,p.bumpMapTransform),p.bumpScale.value=h.bumpScale,h.side===xe&&(p.bumpScale.value*=-1)),h.normalMap&&(p.normalMap.value=h.normalMap,e(h.normalMap,p.normalMapTransform),p.normalScale.value.copy(h.normalScale),h.side===xe&&p.normalScale.value.negate()),h.displacementMap&&(p.displacementMap.value=h.displacementMap,e(h.displacementMap,p.displacementMapTransform),p.displacementScale.value=h.displacementScale,p.displacementBias.value=h.displacementBias),h.emissiveMap&&(p.emissiveMap.value=h.emissiveMap,e(h.emissiveMap,p.emissiveMapTransform)),h.specularMap&&(p.specularMap.value=h.specularMap,e(h.specularMap,p.specularMapTransform)),h.alphaTest>0&&(p.alphaTest.value=h.alphaTest);const E=t.get(h).envMap;if(E&&(p.envMap.value=E,p.flipEnvMap.value=E.isCubeTexture&&E.isRenderTargetTexture===!1?-1:1,p.reflectivity.value=h.reflectivity,p.ior.value=h.ior,p.refractionRatio.value=h.refractionRatio),h.lightMap){p.lightMap.value=h.lightMap;const T=i._useLegacyLights===!0?Math.PI:1;p.lightMapIntensity.value=h.lightMapIntensity*T,e(h.lightMap,p.lightMapTransform)}h.aoMap&&(p.aoMap.value=h.aoMap,p.aoMapIntensity.value=h.aoMapIntensity,e(h.aoMap,p.aoMapTransform))}function o(p,h){p.diffuse.value.copy(h.color),p.opacity.value=h.opacity,h.map&&(p.map.value=h.map,e(h.map,p.mapTransform))}function s(p,h){p.dashSize.value=h.dashSize,p.totalSize.value=h.dashSize+h.gapSize,p.scale.value=h.scale}function l(p,h,E,T){p.diffuse.value.copy(h.color),p.opacity.value=h.opacity,p.size.value=h.size*E,p.scale.value=T*.5,h.map&&(p.map.value=h.map,e(h.map,p.uvTransform)),h.alphaMap&&(p.alphaMap.value=h.alphaMap,e(h.alphaMap,p.alphaMapTransform)),h.alphaTest>0&&(p.alphaTest.value=h.alphaTest)}function c(p,h){p.diffuse.value.copy(h.color),p.opacity.value=h.opacity,p.rotation.value=h.rotation,h.map&&(p.map.value=h.map,e(h.map,p.mapTransform)),h.alphaMap&&(p.alphaMap.value=h.alphaMap,e(h.alphaMap,p.alphaMapTransform)),h.alphaTest>0&&(p.alphaTest.value=h.alphaTest)}function u(p,h){p.specular.value.copy(h.specular),p.shininess.value=Math.max(h.shininess,1e-4)}function d(p,h){h.gradientMap&&(p.gradientMap.value=h.gradientMap)}function f(p,h){p.metalness.value=h.metalness,h.metalnessMap&&(p.metalnessMap.value=h.metalnessMap,e(h.metalnessMap,p.metalnessMapTransform)),p.roughness.value=h.roughness,h.roughnessMap&&(p.roughnessMap.value=h.roughnessMap,e(h.roughnessMap,p.roughnessMapTransform)),t.get(h).envMap&&(p.envMapIntensity.value=h.envMapIntensity)}function m(p,h,E){p.ior.value=h.ior,h.sheen>0&&(p.sheenColor.value.copy(h.sheenColor).multiplyScalar(h.sheen),p.sheenRoughness.value=h.sheenRoughness,h.sheenColorMap&&(p.sheenColorMap.value=h.sheenColorMap,e(h.sheenColorMap,p.sheenColorMapTransform)),h.sheenRoughnessMap&&(p.sheenRoughnessMap.value=h.sheenRoughnessMap,e(h.sheenRoughnessMap,p.sheenRoughnessMapTransform))),h.clearcoat>0&&(p.clearcoat.value=h.clearcoat,p.clearcoatRoughness.value=h.clearcoatRoughness,h.clearcoatMap&&(p.clearcoatMap.value=h.clearcoatMap,e(h.clearcoatMap,p.clearcoatMapTransform)),h.clearcoatRoughnessMap&&(p.clearcoatRoughnessMap.value=h.clearcoatRoughnessMap,e(h.clearcoatRoughnessMap,p.clearcoatRoughnessMapTransform)),h.clearcoatNormalMap&&(p.clearcoatNormalMap.value=h.clearcoatNormalMap,e(h.clearcoatNormalMap,p.clearcoatNormalMapTransform),p.clearcoatNormalScale.value.copy(h.clearcoatNormalScale),h.side===xe&&p.clearcoatNormalScale.value.negate())),h.iridescence>0&&(p.iridescence.value=h.iridescence,p.iridescenceIOR.value=h.iridescenceIOR,p.iridescenceThicknessMinimum.value=h.iridescenceThicknessRange[0],p.iridescenceThicknessMaximum.value=h.iridescenceThicknessRange[1],h.iridescenceMap&&(p.iridescenceMap.value=h.iridescenceMap,e(h.iridescenceMap,p.iridescenceMapTransform)),h.iridescenceThicknessMap&&(p.iridescenceThicknessMap.value=h.iridescenceThicknessMap,e(h.iridescenceThicknessMap,p.iridescenceThicknessMapTransform))),h.transmission>0&&(p.transmission.value=h.transmission,p.transmissionSamplerMap.value=E.texture,p.transmissionSamplerSize.value.set(E.width,E.height),h.transmissionMap&&(p.transmissionMap.value=h.transmissionMap,e(h.transmissionMap,p.transmissionMapTransform)),p.thickness.value=h.thickness,h.thicknessMap&&(p.thicknessMap.value=h.thicknessMap,e(h.thicknessMap,p.thicknessMapTransform)),p.attenuationDistance.value=h.attenuationDistance,p.attenuationColor.value.copy(h.attenuationColor)),h.anisotropy>0&&(p.anisotropyVector.value.set(h.anisotropy*Math.cos(h.anisotropyRotation),h.anisotropy*Math.sin(h.anisotropyRotation)),h.anisotropyMap&&(p.anisotropyMap.value=h.anisotropyMap,e(h.anisotropyMap,p.anisotropyMapTransform))),p.specularIntensity.value=h.specularIntensity,p.specularColor.value.copy(h.specularColor),h.specularColorMap&&(p.specularColorMap.value=h.specularColorMap,e(h.specularColorMap,p.specularColorMapTransform)),h.specularIntensityMap&&(p.specularIntensityMap.value=h.specularIntensityMap,e(h.specularIntensityMap,p.specularIntensityMapTransform))}function v(p,h){h.matcap&&(p.matcap.value=h.matcap)}function _(p,h){const E=t.get(h).light;p.referencePosition.value.setFromMatrixPosition(E.matrixWorld),p.nearDistance.value=E.shadow.camera.near,p.farDistance.value=E.shadow.camera.far}return{refreshFogUniforms:n,refreshMaterialUniforms:r}}function Af(i,t,e,n){let r={},a={},o=[];const s=e.isWebGL2?i.getParameter(i.MAX_UNIFORM_BUFFER_BINDINGS):0;function l(E,T){const b=T.program;n.uniformBlockBinding(E,b)}function c(E,T){let b=r[E.id];b===void 0&&(v(E),b=u(E),r[E.id]=b,E.addEventListener("dispose",p));const D=T.program;n.updateUBOMapping(E,D);const R=t.render.frame;a[E.id]!==R&&(f(E),a[E.id]=R)}function u(E){const T=d();E.__bindingPointIndex=T;const b=i.createBuffer(),D=E.__size,R=E.usage;return i.bindBuffer(i.UNIFORM_BUFFER,b),i.bufferData(i.UNIFORM_BUFFER,D,R),i.bindBuffer(i.UNIFORM_BUFFER,null),i.bindBufferBase(i.UNIFORM_BUFFER,T,b),b}function d(){for(let E=0;E<s;E++)if(o.indexOf(E)===-1)return o.push(E),E;return console.error("THREE.WebGLRenderer: Maximum number of simultaneously usable uniforms groups reached."),0}function f(E){const T=r[E.id],b=E.uniforms,D=E.__cache;i.bindBuffer(i.UNIFORM_BUFFER,T);for(let R=0,w=b.length;R<w;R++){const Z=Array.isArray(b[R])?b[R]:[b[R]];for(let y=0,M=Z.length;y<M;y++){const H=Z[y];if(m(H,R,y,D)===!0){const k=H.__offset,it=Array.isArray(H.value)?H.value:[H.value];let C=0;for(let z=0;z<it.length;z++){const V=it[z],X=_(V);typeof V=="number"||typeof V=="boolean"?(H.__data[0]=V,i.bufferSubData(i.UNIFORM_BUFFER,k+C,H.__data)):V.isMatrix3?(H.__data[0]=V.elements[0],H.__data[1]=V.elements[1],H.__data[2]=V.elements[2],H.__data[3]=0,H.__data[4]=V.elements[3],H.__data[5]=V.elements[4],H.__data[6]=V.elements[5],H.__data[7]=0,H.__data[8]=V.elements[6],H.__data[9]=V.elements[7],H.__data[10]=V.elements[8],H.__data[11]=0):(V.toArray(H.__data,C),C+=X.storage/Float32Array.BYTES_PER_ELEMENT)}i.bufferSubData(i.UNIFORM_BUFFER,k,H.__data)}}}i.bindBuffer(i.UNIFORM_BUFFER,null)}function m(E,T,b,D){const R=E.value,w=T+"_"+b;if(D[w]===void 0)return typeof R=="number"||typeof R=="boolean"?D[w]=R:D[w]=R.clone(),!0;{const Z=D[w];if(typeof R=="number"||typeof R=="boolean"){if(Z!==R)return D[w]=R,!0}else if(Z.equals(R)===!1)return Z.copy(R),!0}return!1}function v(E){const T=E.uniforms;let b=0;const D=16;for(let w=0,Z=T.length;w<Z;w++){const y=Array.isArray(T[w])?T[w]:[T[w]];for(let M=0,H=y.length;M<H;M++){const k=y[M],it=Array.isArray(k.value)?k.value:[k.value];for(let C=0,z=it.length;C<z;C++){const V=it[C],X=_(V),G=b%D;G!==0&&D-G<X.boundary&&(b+=D-G),k.__data=new Float32Array(X.storage/Float32Array.BYTES_PER_ELEMENT),k.__offset=b,b+=X.storage}}}const R=b%D;return R>0&&(b+=D-R),E.__size=b,E.__cache={},this}function _(E){const T={boundary:0,storage:0};return typeof E=="number"||typeof E=="boolean"?(T.boundary=4,T.storage=4):E.isVector2?(T.boundary=8,T.storage=8):E.isVector3||E.isColor?(T.boundary=16,T.storage=12):E.isVector4?(T.boundary=16,T.storage=16):E.isMatrix3?(T.boundary=48,T.storage=48):E.isMatrix4?(T.boundary=64,T.storage=64):E.isTexture?console.warn("THREE.WebGLRenderer: Texture samplers can not be part of an uniforms group."):console.warn("THREE.WebGLRenderer: Unsupported uniform value type.",E),T}function p(E){const T=E.target;T.removeEventListener("dispose",p);const b=o.indexOf(T.__bindingPointIndex);o.splice(b,1),i.deleteBuffer(r[T.id]),delete r[T.id],delete a[T.id]}function h(){for(const E in r)i.deleteBuffer(r[E]);o=[],r={},a={}}return{bind:l,update:c,dispose:h}}class lo{constructor(t={}){const{canvas:e=Sl(),context:n=null,depth:r=!0,stencil:a=!0,alpha:o=!1,antialias:s=!1,premultipliedAlpha:l=!0,preserveDrawingBuffer:c=!1,powerPreference:u="default",failIfMajorPerformanceCaveat:d=!1}=t;this.isWebGLRenderer=!0;let f;n!==null?f=n.getContextAttributes().alpha:f=o;const m=new Uint32Array(4),v=new Int32Array(4);let _=null,p=null;const h=[],E=[];this.domElement=e,this.debug={checkShaderErrors:!0,onShaderError:null},this.autoClear=!0,this.autoClearColor=!0,this.autoClearDepth=!0,this.autoClearStencil=!0,this.sortObjects=!0,this.clippingPlanes=[],this.localClippingEnabled=!1,this._outputColorSpace=le,this._useLegacyLights=!1,this.toneMapping=ln,this.toneMappingExposure=1;const T=this;let b=!1,D=0,R=0,w=null,Z=-1,y=null;const M=new ce,H=new ce;let k=null;const it=new kt(0);let C=0,z=e.width,V=e.height,X=1,G=null,W=null;const q=new ce(0,0,z,V),Q=new ce(0,0,z,V);let tt=!1;const B=new Qs;let Y=!1,ot=!1,mt=null;const pt=new Kt,wt=new Wt,Pt=new L,yt={background:null,fog:null,environment:null,overrideMaterial:null,isScene:!0};function Bt(){return w===null?X:1}let U=n;function fe(x,P){for(let F=0;F<x.length;F++){const O=x[F],I=e.getContext(O,P);if(I!==null)return I}return null}try{const x={alpha:!0,depth:r,stencil:a,antialias:s,premultipliedAlpha:l,preserveDrawingBuffer:c,powerPreference:u,failIfMajorPerformanceCaveat:d};if("setAttribute"in e&&e.setAttribute("data-engine",`three.js r${Xr}`),e.addEventListener("webglcontextlost",et,!1),e.addEventListener("webglcontextrestored",A,!1),e.addEventListener("webglcontextcreationerror",rt,!1),U===null){const P=["webgl2","webgl","experimental-webgl"];if(T.isWebGL1Renderer===!0&&P.shift(),U=fe(P,x),U===null)throw fe(P)?new Error("Error creating WebGL context with your selected attributes."):new Error("Error creating WebGL context.")}typeof WebGLRenderingContext<"u"&&U instanceof WebGLRenderingContext&&console.warn("THREE.WebGLRenderer: WebGL 1 support was deprecated in r153 and will be removed in r163."),U.getShaderPrecisionFormat===void 0&&(U.getShaderPrecisionFormat=function(){return{rangeMin:1,rangeMax:1,precision:1}})}catch(x){throw console.error("THREE.WebGLRenderer: "+x.message),x}let _t,bt,ht,jt,Ut,S,g,N,K,j,J,dt,st,ct,St,It,$,Ht,zt,Et,gt,ut,Lt,Vt;function Jt(){_t=new Nh(U),bt=new Ch(U,_t,t),_t.init(bt),ut=new yf(U,_t,bt),ht=new xf(U,_t,bt),jt=new zh(U),Ut=new af,S=new Sf(U,_t,ht,Ut,bt,ut,jt),g=new Lh(T),N=new Ih(T),K=new ql(U,bt),Lt=new wh(U,_t,K,bt),j=new Fh(U,K,jt,Lt),J=new Gh(U,j,K,jt),zt=new Hh(U,bt,S),It=new Ph(Ut),dt=new rf(T,g,N,_t,bt,Lt,It),st=new bf(T,Ut),ct=new of,St=new ff(_t,bt),Ht=new Ah(T,g,N,ht,J,f,l),$=new vf(T,J,bt),Vt=new Af(U,jt,bt,ht),Et=new Rh(U,_t,jt,bt),gt=new Oh(U,_t,jt,bt),jt.programs=dt.programs,T.capabilities=bt,T.extensions=_t,T.properties=Ut,T.renderLists=ct,T.shadowMap=$,T.state=ht,T.info=jt}Jt();const Ft=new Ef(T,U);this.xr=Ft,this.getContext=function(){return U},this.getContextAttributes=function(){return U.getContextAttributes()},this.forceContextLoss=function(){const x=_t.get("WEBGL_lose_context");x&&x.loseContext()},this.forceContextRestore=function(){const x=_t.get("WEBGL_lose_context");x&&x.restoreContext()},this.getPixelRatio=function(){return X},this.setPixelRatio=function(x){x!==void 0&&(X=x,this.setSize(z,V,!1))},this.getSize=function(x){return x.set(z,V)},this.setSize=function(x,P,F=!0){if(Ft.isPresenting){console.warn("THREE.WebGLRenderer: Can't change size while VR device is presenting.");return}z=x,V=P,e.width=Math.floor(x*X),e.height=Math.floor(P*X),F===!0&&(e.style.width=x+"px",e.style.height=P+"px"),this.setViewport(0,0,x,P)},this.getDrawingBufferSize=function(x){return x.set(z*X,V*X).floor()},this.setDrawingBufferSize=function(x,P,F){z=x,V=P,X=F,e.width=Math.floor(x*F),e.height=Math.floor(P*F),this.setViewport(0,0,x,P)},this.getCurrentViewport=function(x){return x.copy(M)},this.getViewport=function(x){return x.copy(q)},this.setViewport=function(x,P,F,O){x.isVector4?q.set(x.x,x.y,x.z,x.w):q.set(x,P,F,O),ht.viewport(M.copy(q).multiplyScalar(X).floor())},this.getScissor=function(x){return x.copy(Q)},this.setScissor=function(x,P,F,O){x.isVector4?Q.set(x.x,x.y,x.z,x.w):Q.set(x,P,F,O),ht.scissor(H.copy(Q).multiplyScalar(X).floor())},this.getScissorTest=function(){return tt},this.setScissorTest=function(x){ht.setScissorTest(tt=x)},this.setOpaqueSort=function(x){G=x},this.setTransparentSort=function(x){W=x},this.getClearColor=function(x){return x.copy(Ht.getClearColor())},this.setClearColor=function(){Ht.setClearColor.apply(Ht,arguments)},this.getClearAlpha=function(){return Ht.getClearAlpha()},this.setClearAlpha=function(){Ht.setClearAlpha.apply(Ht,arguments)},this.clear=function(x=!0,P=!0,F=!0){let O=0;if(x){let I=!1;if(w!==null){const lt=w.texture.format;I=lt===Os||lt===Fs||lt===Ns}if(I){const lt=w.texture.type,ft=lt===cn||lt===sn||lt===qr||lt===Mn||lt===Us||lt===Is,xt=Ht.getClearColor(),Mt=Ht.getClearAlpha(),Nt=xt.r,At=xt.g,Rt=xt.b;ft?(m[0]=Nt,m[1]=At,m[2]=Rt,m[3]=Mt,U.clearBufferuiv(U.COLOR,0,m)):(v[0]=Nt,v[1]=At,v[2]=Rt,v[3]=Mt,U.clearBufferiv(U.COLOR,0,v))}else O|=U.COLOR_BUFFER_BIT}P&&(O|=U.DEPTH_BUFFER_BIT),F&&(O|=U.STENCIL_BUFFER_BIT,this.state.buffers.stencil.setMask(4294967295)),U.clear(O)},this.clearColor=function(){this.clear(!0,!1,!1)},this.clearDepth=function(){this.clear(!1,!0,!1)},this.clearStencil=function(){this.clear(!1,!1,!0)},this.dispose=function(){e.removeEventListener("webglcontextlost",et,!1),e.removeEventListener("webglcontextrestored",A,!1),e.removeEventListener("webglcontextcreationerror",rt,!1),ct.dispose(),St.dispose(),Ut.dispose(),g.dispose(),N.dispose(),J.dispose(),Lt.dispose(),Vt.dispose(),dt.dispose(),Ft.dispose(),Ft.removeEventListener("sessionstart",pe),Ft.removeEventListener("sessionend",Yt),mt&&(mt.dispose(),mt=null),me.stop()};function et(x){x.preventDefault(),console.log("THREE.WebGLRenderer: Context Lost."),b=!0}function A(){console.log("THREE.WebGLRenderer: Context Restored."),b=!1;const x=jt.autoReset,P=$.enabled,F=$.autoUpdate,O=$.needsUpdate,I=$.type;Jt(),jt.autoReset=x,$.enabled=P,$.autoUpdate=F,$.needsUpdate=O,$.type=I}function rt(x){console.error("THREE.WebGLRenderer: A WebGL context could not be created. Reason: ",x.statusMessage)}function at(x){const P=x.target;P.removeEventListener("dispose",at),Tt(P)}function Tt(x){vt(x),Ut.remove(x)}function vt(x){const P=Ut.get(x).programs;P!==void 0&&(P.forEach(function(F){dt.releaseProgram(F)}),x.isShaderMaterial&&dt.releaseShaderCache(x))}this.renderBufferDirect=function(x,P,F,O,I,lt){P===null&&(P=yt);const ft=I.isMesh&&I.matrixWorld.determinant()<0,xt=mo(x,P,F,O,I);ht.setMaterial(O,ft);let Mt=F.index,Nt=1;if(O.wireframe===!0){if(Mt=j.getWireframeAttribute(F),Mt===void 0)return;Nt=2}const At=F.drawRange,Rt=F.attributes.position;let te=At.start*Nt,ye=(At.start+At.count)*Nt;lt!==null&&(te=Math.max(te,lt.start*Nt),ye=Math.min(ye,(lt.start+lt.count)*Nt)),Mt!==null?(te=Math.max(te,0),ye=Math.min(ye,Mt.count)):Rt!=null&&(te=Math.max(te,0),ye=Math.min(ye,Rt.count));const ae=ye-te;if(ae<0||ae===1/0)return;Lt.setup(I,O,xt,F,Mt);let Ve,Zt=Et;if(Mt!==null&&(Ve=K.get(Mt),Zt=gt,Zt.setIndex(Ve)),I.isMesh)O.wireframe===!0?(ht.setLineWidth(O.wireframeLinewidth*Bt()),Zt.setMode(U.LINES)):Zt.setMode(U.TRIANGLES);else if(I.isLine){let Ot=O.linewidth;Ot===void 0&&(Ot=1),ht.setLineWidth(Ot*Bt()),I.isLineSegments?Zt.setMode(U.LINES):I.isLineLoop?Zt.setMode(U.LINE_LOOP):Zt.setMode(U.LINE_STRIP)}else I.isPoints?Zt.setMode(U.POINTS):I.isSprite&&Zt.setMode(U.TRIANGLES);if(I.isBatchedMesh)Zt.renderMultiDraw(I._multiDrawStarts,I._multiDrawCounts,I._multiDrawCount);else if(I.isInstancedMesh)Zt.renderInstances(te,ae,I.count);else if(F.isInstancedBufferGeometry){const Ot=F._maxInstanceCount!==void 0?F._maxInstanceCount:1/0,Ki=Math.min(F.instanceCount,Ot);Zt.renderInstances(te,ae,Ki)}else Zt.render(te,ae)};function Xt(x,P,F){x.transparent===!0&&x.side===Ye&&x.forceSinglePass===!1?(x.side=xe,x.needsUpdate=!0,mi(x,P,F),x.side=un,x.needsUpdate=!0,mi(x,P,F),x.side=Ye):mi(x,P,F)}this.compile=function(x,P,F=null){F===null&&(F=x),p=St.get(F),p.init(),E.push(p),F.traverseVisible(function(I){I.isLight&&I.layers.test(P.layers)&&(p.pushLight(I),I.castShadow&&p.pushShadow(I))}),x!==F&&x.traverseVisible(function(I){I.isLight&&I.layers.test(P.layers)&&(p.pushLight(I),I.castShadow&&p.pushShadow(I))}),p.setupLights(T._useLegacyLights);const O=new Set;return x.traverse(function(I){const lt=I.material;if(lt)if(Array.isArray(lt))for(let ft=0;ft<lt.length;ft++){const xt=lt[ft];Xt(xt,F,I),O.add(xt)}else Xt(lt,F,I),O.add(lt)}),E.pop(),p=null,O},this.compileAsync=function(x,P,F=null){const O=this.compile(x,P,F);return new Promise(I=>{function lt(){if(O.forEach(function(ft){Ut.get(ft).currentProgram.isReady()&&O.delete(ft)}),O.size===0){I(x);return}setTimeout(lt,10)}_t.get("KHR_parallel_shader_compile")!==null?lt():setTimeout(lt,10)})};let qt=null;function re(x){qt&&qt(x)}function pe(){me.stop()}function Yt(){me.start()}const me=new to;me.setAnimationLoop(re),typeof self<"u"&&me.setContext(self),this.setAnimationLoop=function(x){qt=x,Ft.setAnimationLoop(x),x===null?me.stop():me.start()},Ft.addEventListener("sessionstart",pe),Ft.addEventListener("sessionend",Yt),this.render=function(x,P){if(P!==void 0&&P.isCamera!==!0){console.error("THREE.WebGLRenderer.render: camera is not an instance of THREE.Camera.");return}if(b===!0)return;x.matrixWorldAutoUpdate===!0&&x.updateMatrixWorld(),P.parent===null&&P.matrixWorldAutoUpdate===!0&&P.updateMatrixWorld(),Ft.enabled===!0&&Ft.isPresenting===!0&&(Ft.cameraAutoUpdate===!0&&Ft.updateCamera(P),P=Ft.getCamera()),x.isScene===!0&&x.onBeforeRender(T,x,P,w),p=St.get(x,E.length),p.init(),E.push(p),pt.multiplyMatrices(P.projectionMatrix,P.matrixWorldInverse),B.setFromProjectionMatrix(pt),ot=this.localClippingEnabled,Y=It.init(this.clippingPlanes,ot),_=ct.get(x,h.length),_.init(),h.push(_),Fe(x,P,0,T.sortObjects),_.finish(),T.sortObjects===!0&&_.sort(G,W),this.info.render.frame++,Y===!0&&It.beginShadows();const F=p.state.shadowsArray;if($.render(F,x,P),Y===!0&&It.endShadows(),this.info.autoReset===!0&&this.info.reset(),Ht.render(_,x),p.setupLights(T._useLegacyLights),P.isArrayCamera){const O=P.cameras;for(let I=0,lt=O.length;I<lt;I++){const ft=O[I];ta(_,x,ft,ft.viewport)}}else ta(_,x,P);w!==null&&(S.updateMultisampleRenderTarget(w),S.updateRenderTargetMipmap(w)),x.isScene===!0&&x.onAfterRender(T,x,P),Lt.resetDefaultState(),Z=-1,y=null,E.pop(),E.length>0?p=E[E.length-1]:p=null,h.pop(),h.length>0?_=h[h.length-1]:_=null};function Fe(x,P,F,O){if(x.visible===!1)return;if(x.layers.test(P.layers)){if(x.isGroup)F=x.renderOrder;else if(x.isLOD)x.autoUpdate===!0&&x.update(P);else if(x.isLight)p.pushLight(x),x.castShadow&&p.pushShadow(x);else if(x.isSprite){if(!x.frustumCulled||B.intersectsSprite(x)){O&&Pt.setFromMatrixPosition(x.matrixWorld).applyMatrix4(pt);const ft=J.update(x),xt=x.material;xt.visible&&_.push(x,ft,xt,F,Pt.z,null)}}else if((x.isMesh||x.isLine||x.isPoints)&&(!x.frustumCulled||B.intersectsObject(x))){const ft=J.update(x),xt=x.material;if(O&&(x.boundingSphere!==void 0?(x.boundingSphere===null&&x.computeBoundingSphere(),Pt.copy(x.boundingSphere.center)):(ft.boundingSphere===null&&ft.computeBoundingSphere(),Pt.copy(ft.boundingSphere.center)),Pt.applyMatrix4(x.matrixWorld).applyMatrix4(pt)),Array.isArray(xt)){const Mt=ft.groups;for(let Nt=0,At=Mt.length;Nt<At;Nt++){const Rt=Mt[Nt],te=xt[Rt.materialIndex];te&&te.visible&&_.push(x,ft,te,F,Pt.z,Rt)}}else xt.visible&&_.push(x,ft,xt,F,Pt.z,null)}}const lt=x.children;for(let ft=0,xt=lt.length;ft<xt;ft++)Fe(lt[ft],P,F,O)}function ta(x,P,F,O){const I=x.opaque,lt=x.transmissive,ft=x.transparent;p.setupLightsView(F),Y===!0&&It.setGlobalState(T.clippingPlanes,F),lt.length>0&&po(I,lt,P,F),O&&ht.viewport(M.copy(O)),I.length>0&&pi(I,P,F),lt.length>0&&pi(lt,P,F),ft.length>0&&pi(ft,P,F),ht.buffers.depth.setTest(!0),ht.buffers.depth.setMask(!0),ht.buffers.color.setMask(!0),ht.setPolygonOffset(!1)}function po(x,P,F,O){if((F.isScene===!0?F.overrideMaterial:null)!==null)return;const lt=bt.isWebGL2;mt===null&&(mt=new Qe(1,1,{generateMipmaps:!0,type:_t.has("EXT_color_buffer_half_float")?oi:cn,minFilter:si,samples:lt?4:0})),T.getDrawingBufferSize(wt),lt?mt.setSize(wt.x,wt.y):mt.setSize(Gr(wt.x),Gr(wt.y));const ft=T.getRenderTarget();T.setRenderTarget(mt),T.getClearColor(it),C=T.getClearAlpha(),C<1&&T.setClearColor(16777215,.5),T.clear();const xt=T.toneMapping;T.toneMapping=ln,pi(x,F,O),S.updateMultisampleRenderTarget(mt),S.updateRenderTargetMipmap(mt);let Mt=!1;for(let Nt=0,At=P.length;Nt<At;Nt++){const Rt=P[Nt],te=Rt.object,ye=Rt.geometry,ae=Rt.material,Ve=Rt.group;if(ae.side===Ye&&te.layers.test(O.layers)){const Zt=ae.side;ae.side=xe,ae.needsUpdate=!0,ea(te,F,O,ye,ae,Ve),ae.side=Zt,ae.needsUpdate=!0,Mt=!0}}Mt===!0&&(S.updateMultisampleRenderTarget(mt),S.updateRenderTargetMipmap(mt)),T.setRenderTarget(ft),T.setClearColor(it,C),T.toneMapping=xt}function pi(x,P,F){const O=P.isScene===!0?P.overrideMaterial:null;for(let I=0,lt=x.length;I<lt;I++){const ft=x[I],xt=ft.object,Mt=ft.geometry,Nt=O===null?ft.material:O,At=ft.group;xt.layers.test(F.layers)&&ea(xt,P,F,Mt,Nt,At)}}function ea(x,P,F,O,I,lt){x.onBeforeRender(T,P,F,O,I,lt),x.modelViewMatrix.multiplyMatrices(F.matrixWorldInverse,x.matrixWorld),x.normalMatrix.getNormalMatrix(x.modelViewMatrix),I.onBeforeRender(T,P,F,O,x,lt),I.transparent===!0&&I.side===Ye&&I.forceSinglePass===!1?(I.side=xe,I.needsUpdate=!0,T.renderBufferDirect(F,P,O,I,x,lt),I.side=un,I.needsUpdate=!0,T.renderBufferDirect(F,P,O,I,x,lt),I.side=Ye):T.renderBufferDirect(F,P,O,I,x,lt),x.onAfterRender(T,P,F,O,I,lt)}function mi(x,P,F){P.isScene!==!0&&(P=yt);const O=Ut.get(x),I=p.state.lights,lt=p.state.shadowsArray,ft=I.state.version,xt=dt.getParameters(x,I.state,lt,P,F),Mt=dt.getProgramCacheKey(xt);let Nt=O.programs;O.environment=x.isMeshStandardMaterial?P.environment:null,O.fog=P.fog,O.envMap=(x.isMeshStandardMaterial?N:g).get(x.envMap||O.environment),Nt===void 0&&(x.addEventListener("dispose",at),Nt=new Map,O.programs=Nt);let At=Nt.get(Mt);if(At!==void 0){if(O.currentProgram===At&&O.lightsStateVersion===ft)return ia(x,xt),At}else xt.uniforms=dt.getUniforms(x),x.onBuild(F,xt,T),x.onBeforeCompile(xt,T),At=dt.acquireProgram(xt,Mt),Nt.set(Mt,At),O.uniforms=xt.uniforms;const Rt=O.uniforms;return(!x.isShaderMaterial&&!x.isRawShaderMaterial||x.clipping===!0)&&(Rt.clippingPlanes=It.uniform),ia(x,xt),O.needsLights=_o(x),O.lightsStateVersion=ft,O.needsLights&&(Rt.ambientLightColor.value=I.state.ambient,Rt.lightProbe.value=I.state.probe,Rt.directionalLights.value=I.state.directional,Rt.directionalLightShadows.value=I.state.directionalShadow,Rt.spotLights.value=I.state.spot,Rt.spotLightShadows.value=I.state.spotShadow,Rt.rectAreaLights.value=I.state.rectArea,Rt.ltc_1.value=I.state.rectAreaLTC1,Rt.ltc_2.value=I.state.rectAreaLTC2,Rt.pointLights.value=I.state.point,Rt.pointLightShadows.value=I.state.pointShadow,Rt.hemisphereLights.value=I.state.hemi,Rt.directionalShadowMap.value=I.state.directionalShadowMap,Rt.directionalShadowMatrix.value=I.state.directionalShadowMatrix,Rt.spotShadowMap.value=I.state.spotShadowMap,Rt.spotLightMatrix.value=I.state.spotLightMatrix,Rt.spotLightMap.value=I.state.spotLightMap,Rt.pointShadowMap.value=I.state.pointShadowMap,Rt.pointShadowMatrix.value=I.state.pointShadowMatrix),O.currentProgram=At,O.uniformsList=null,At}function na(x){if(x.uniformsList===null){const P=x.currentProgram.getUniforms();x.uniformsList=Bi.seqWithValue(P.seq,x.uniforms)}return x.uniformsList}function ia(x,P){const F=Ut.get(x);F.outputColorSpace=P.outputColorSpace,F.batching=P.batching,F.instancing=P.instancing,F.instancingColor=P.instancingColor,F.skinning=P.skinning,F.morphTargets=P.morphTargets,F.morphNormals=P.morphNormals,F.morphColors=P.morphColors,F.morphTargetsCount=P.morphTargetsCount,F.numClippingPlanes=P.numClippingPlanes,F.numIntersection=P.numClipIntersection,F.vertexAlphas=P.vertexAlphas,F.vertexTangents=P.vertexTangents,F.toneMapping=P.toneMapping}function mo(x,P,F,O,I){P.isScene!==!0&&(P=yt),S.resetTextureUnits();const lt=P.fog,ft=O.isMeshStandardMaterial?P.environment:null,xt=w===null?T.outputColorSpace:w.isXRRenderTarget===!0?w.texture.colorSpace:Je,Mt=(O.isMeshStandardMaterial?N:g).get(O.envMap||ft),Nt=O.vertexColors===!0&&!!F.attributes.color&&F.attributes.color.itemSize===4,At=!!F.attributes.tangent&&(!!O.normalMap||O.anisotropy>0),Rt=!!F.morphAttributes.position,te=!!F.morphAttributes.normal,ye=!!F.morphAttributes.color;let ae=ln;O.toneMapped&&(w===null||w.isXRRenderTarget===!0)&&(ae=T.toneMapping);const Ve=F.morphAttributes.position||F.morphAttributes.normal||F.morphAttributes.color,Zt=Ve!==void 0?Ve.length:0,Ot=Ut.get(O),Ki=p.state.lights;if(Y===!0&&(ot===!0||x!==y)){const Ae=x===y&&O.id===Z;It.setState(O,x,Ae)}let Qt=!1;O.version===Ot.__version?(Ot.needsLights&&Ot.lightsStateVersion!==Ki.state.version||Ot.outputColorSpace!==xt||I.isBatchedMesh&&Ot.batching===!1||!I.isBatchedMesh&&Ot.batching===!0||I.isInstancedMesh&&Ot.instancing===!1||!I.isInstancedMesh&&Ot.instancing===!0||I.isSkinnedMesh&&Ot.skinning===!1||!I.isSkinnedMesh&&Ot.skinning===!0||I.isInstancedMesh&&Ot.instancingColor===!0&&I.instanceColor===null||I.isInstancedMesh&&Ot.instancingColor===!1&&I.instanceColor!==null||Ot.envMap!==Mt||O.fog===!0&&Ot.fog!==lt||Ot.numClippingPlanes!==void 0&&(Ot.numClippingPlanes!==It.numPlanes||Ot.numIntersection!==It.numIntersection)||Ot.vertexAlphas!==Nt||Ot.vertexTangents!==At||Ot.morphTargets!==Rt||Ot.morphNormals!==te||Ot.morphColors!==ye||Ot.toneMapping!==ae||bt.isWebGL2===!0&&Ot.morphTargetsCount!==Zt)&&(Qt=!0):(Qt=!0,Ot.__version=O.version);let fn=Ot.currentProgram;Qt===!0&&(fn=mi(O,P,I));let ra=!1,Jn=!1,Ji=!1;const ue=fn.getUniforms(),pn=Ot.uniforms;if(ht.useProgram(fn.program)&&(ra=!0,Jn=!0,Ji=!0),O.id!==Z&&(Z=O.id,Jn=!0),ra||y!==x){ue.setValue(U,"projectionMatrix",x.projectionMatrix),ue.setValue(U,"viewMatrix",x.matrixWorldInverse);const Ae=ue.map.cameraPosition;Ae!==void 0&&Ae.setValue(U,Pt.setFromMatrixPosition(x.matrixWorld)),bt.logarithmicDepthBuffer&&ue.setValue(U,"logDepthBufFC",2/(Math.log(x.far+1)/Math.LN2)),(O.isMeshPhongMaterial||O.isMeshToonMaterial||O.isMeshLambertMaterial||O.isMeshBasicMaterial||O.isMeshStandardMaterial||O.isShaderMaterial)&&ue.setValue(U,"isOrthographic",x.isOrthographicCamera===!0),y!==x&&(y=x,Jn=!0,Ji=!0)}if(I.isSkinnedMesh){ue.setOptional(U,I,"bindMatrix"),ue.setOptional(U,I,"bindMatrixInverse");const Ae=I.skeleton;Ae&&(bt.floatVertexTextures?(Ae.boneTexture===null&&Ae.computeBoneTexture(),ue.setValue(U,"boneTexture",Ae.boneTexture,S)):console.warn("THREE.WebGLRenderer: SkinnedMesh can only be used with WebGL 2. With WebGL 1 OES_texture_float and vertex textures support is required."))}I.isBatchedMesh&&(ue.setOptional(U,I,"batchingTexture"),ue.setValue(U,"batchingTexture",I._matricesTexture,S));const Qi=F.morphAttributes;if((Qi.position!==void 0||Qi.normal!==void 0||Qi.color!==void 0&&bt.isWebGL2===!0)&&zt.update(I,F,fn),(Jn||Ot.receiveShadow!==I.receiveShadow)&&(Ot.receiveShadow=I.receiveShadow,ue.setValue(U,"receiveShadow",I.receiveShadow)),O.isMeshGouraudMaterial&&O.envMap!==null&&(pn.envMap.value=Mt,pn.flipEnvMap.value=Mt.isCubeTexture&&Mt.isRenderTargetTexture===!1?-1:1),Jn&&(ue.setValue(U,"toneMappingExposure",T.toneMappingExposure),Ot.needsLights&&go(pn,Ji),lt&&O.fog===!0&&st.refreshFogUniforms(pn,lt),st.refreshMaterialUniforms(pn,O,X,V,mt),Bi.upload(U,na(Ot),pn,S)),O.isShaderMaterial&&O.uniformsNeedUpdate===!0&&(Bi.upload(U,na(Ot),pn,S),O.uniformsNeedUpdate=!1),O.isSpriteMaterial&&ue.setValue(U,"center",I.center),ue.setValue(U,"modelViewMatrix",I.modelViewMatrix),ue.setValue(U,"normalMatrix",I.normalMatrix),ue.setValue(U,"modelMatrix",I.matrixWorld),O.isShaderMaterial||O.isRawShaderMaterial){const Ae=O.uniformsGroups;for(let tr=0,vo=Ae.length;tr<vo;tr++)if(bt.isWebGL2){const aa=Ae[tr];Vt.update(aa,fn),Vt.bind(aa,fn)}else console.warn("THREE.WebGLRenderer: Uniform Buffer Objects can only be used with WebGL 2.")}return fn}function go(x,P){x.ambientLightColor.needsUpdate=P,x.lightProbe.needsUpdate=P,x.directionalLights.needsUpdate=P,x.directionalLightShadows.needsUpdate=P,x.pointLights.needsUpdate=P,x.pointLightShadows.needsUpdate=P,x.spotLights.needsUpdate=P,x.spotLightShadows.needsUpdate=P,x.rectAreaLights.needsUpdate=P,x.hemisphereLights.needsUpdate=P}function _o(x){return x.isMeshLambertMaterial||x.isMeshToonMaterial||x.isMeshPhongMaterial||x.isMeshStandardMaterial||x.isShadowMaterial||x.isShaderMaterial&&x.lights===!0}this.getActiveCubeFace=function(){return D},this.getActiveMipmapLevel=function(){return R},this.getRenderTarget=function(){return w},this.setRenderTargetTextures=function(x,P,F){Ut.get(x.texture).__webglTexture=P,Ut.get(x.depthTexture).__webglTexture=F;const O=Ut.get(x);O.__hasExternalTextures=!0,O.__hasExternalTextures&&(O.__autoAllocateDepthBuffer=F===void 0,O.__autoAllocateDepthBuffer||_t.has("WEBGL_multisampled_render_to_texture")===!0&&(console.warn("THREE.WebGLRenderer: Render-to-texture extension was disabled because an external texture was provided"),O.__useRenderToTexture=!1))},this.setRenderTargetFramebuffer=function(x,P){const F=Ut.get(x);F.__webglFramebuffer=P,F.__useDefaultFramebuffer=P===void 0},this.setRenderTarget=function(x,P=0,F=0){w=x,D=P,R=F;let O=!0,I=null,lt=!1,ft=!1;if(x){const Mt=Ut.get(x);Mt.__useDefaultFramebuffer!==void 0?(ht.bindFramebuffer(U.FRAMEBUFFER,null),O=!1):Mt.__webglFramebuffer===void 0?S.setupRenderTarget(x):Mt.__hasExternalTextures&&S.rebindTextures(x,Ut.get(x.texture).__webglTexture,Ut.get(x.depthTexture).__webglTexture);const Nt=x.texture;(Nt.isData3DTexture||Nt.isDataArrayTexture||Nt.isCompressedArrayTexture)&&(ft=!0);const At=Ut.get(x).__webglFramebuffer;x.isWebGLCubeRenderTarget?(Array.isArray(At[P])?I=At[P][F]:I=At[P],lt=!0):bt.isWebGL2&&x.samples>0&&S.useMultisampledRTT(x)===!1?I=Ut.get(x).__webglMultisampledFramebuffer:Array.isArray(At)?I=At[F]:I=At,M.copy(x.viewport),H.copy(x.scissor),k=x.scissorTest}else M.copy(q).multiplyScalar(X).floor(),H.copy(Q).multiplyScalar(X).floor(),k=tt;if(ht.bindFramebuffer(U.FRAMEBUFFER,I)&&bt.drawBuffers&&O&&ht.drawBuffers(x,I),ht.viewport(M),ht.scissor(H),ht.setScissorTest(k),lt){const Mt=Ut.get(x.texture);U.framebufferTexture2D(U.FRAMEBUFFER,U.COLOR_ATTACHMENT0,U.TEXTURE_CUBE_MAP_POSITIVE_X+P,Mt.__webglTexture,F)}else if(ft){const Mt=Ut.get(x.texture),Nt=P||0;U.framebufferTextureLayer(U.FRAMEBUFFER,U.COLOR_ATTACHMENT0,Mt.__webglTexture,F||0,Nt)}Z=-1},this.readRenderTargetPixels=function(x,P,F,O,I,lt,ft){if(!(x&&x.isWebGLRenderTarget)){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not THREE.WebGLRenderTarget.");return}let xt=Ut.get(x).__webglFramebuffer;if(x.isWebGLCubeRenderTarget&&ft!==void 0&&(xt=xt[ft]),xt){ht.bindFramebuffer(U.FRAMEBUFFER,xt);try{const Mt=x.texture,Nt=Mt.format,At=Mt.type;if(Nt!==Ce&&ut.convert(Nt)!==U.getParameter(U.IMPLEMENTATION_COLOR_READ_FORMAT)){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not in RGBA or implementation defined format.");return}const Rt=At===oi&&(_t.has("EXT_color_buffer_half_float")||bt.isWebGL2&&_t.has("EXT_color_buffer_float"));if(At!==cn&&ut.convert(At)!==U.getParameter(U.IMPLEMENTATION_COLOR_READ_TYPE)&&!(At===$e&&(bt.isWebGL2||_t.has("OES_texture_float")||_t.has("WEBGL_color_buffer_float")))&&!Rt){console.error("THREE.WebGLRenderer.readRenderTargetPixels: renderTarget is not in UnsignedByteType or implementation defined type.");return}P>=0&&P<=x.width-O&&F>=0&&F<=x.height-I&&U.readPixels(P,F,O,I,ut.convert(Nt),ut.convert(At),lt)}finally{const Mt=w!==null?Ut.get(w).__webglFramebuffer:null;ht.bindFramebuffer(U.FRAMEBUFFER,Mt)}}},this.copyFramebufferToTexture=function(x,P,F=0){const O=Math.pow(2,-F),I=Math.floor(P.image.width*O),lt=Math.floor(P.image.height*O);S.setTexture2D(P,0),U.copyTexSubImage2D(U.TEXTURE_2D,F,0,0,x.x,x.y,I,lt),ht.unbindTexture()},this.copyTextureToTexture=function(x,P,F,O=0){const I=P.image.width,lt=P.image.height,ft=ut.convert(F.format),xt=ut.convert(F.type);S.setTexture2D(F,0),U.pixelStorei(U.UNPACK_FLIP_Y_WEBGL,F.flipY),U.pixelStorei(U.UNPACK_PREMULTIPLY_ALPHA_WEBGL,F.premultiplyAlpha),U.pixelStorei(U.UNPACK_ALIGNMENT,F.unpackAlignment),P.isDataTexture?U.texSubImage2D(U.TEXTURE_2D,O,x.x,x.y,I,lt,ft,xt,P.image.data):P.isCompressedTexture?U.compressedTexSubImage2D(U.TEXTURE_2D,O,x.x,x.y,P.mipmaps[0].width,P.mipmaps[0].height,ft,P.mipmaps[0].data):U.texSubImage2D(U.TEXTURE_2D,O,x.x,x.y,ft,xt,P.image),O===0&&F.generateMipmaps&&U.generateMipmap(U.TEXTURE_2D),ht.unbindTexture()},this.copyTextureToTexture3D=function(x,P,F,O,I=0){if(T.isWebGL1Renderer){console.warn("THREE.WebGLRenderer.copyTextureToTexture3D: can only be used with WebGL2.");return}const lt=x.max.x-x.min.x+1,ft=x.max.y-x.min.y+1,xt=x.max.z-x.min.z+1,Mt=ut.convert(O.format),Nt=ut.convert(O.type);let At;if(O.isData3DTexture)S.setTexture3D(O,0),At=U.TEXTURE_3D;else if(O.isDataArrayTexture||O.isCompressedArrayTexture)S.setTexture2DArray(O,0),At=U.TEXTURE_2D_ARRAY;else{console.warn("THREE.WebGLRenderer.copyTextureToTexture3D: only supports THREE.DataTexture3D and THREE.DataTexture2DArray.");return}U.pixelStorei(U.UNPACK_FLIP_Y_WEBGL,O.flipY),U.pixelStorei(U.UNPACK_PREMULTIPLY_ALPHA_WEBGL,O.premultiplyAlpha),U.pixelStorei(U.UNPACK_ALIGNMENT,O.unpackAlignment);const Rt=U.getParameter(U.UNPACK_ROW_LENGTH),te=U.getParameter(U.UNPACK_IMAGE_HEIGHT),ye=U.getParameter(U.UNPACK_SKIP_PIXELS),ae=U.getParameter(U.UNPACK_SKIP_ROWS),Ve=U.getParameter(U.UNPACK_SKIP_IMAGES),Zt=F.isCompressedTexture?F.mipmaps[I]:F.image;U.pixelStorei(U.UNPACK_ROW_LENGTH,Zt.width),U.pixelStorei(U.UNPACK_IMAGE_HEIGHT,Zt.height),U.pixelStorei(U.UNPACK_SKIP_PIXELS,x.min.x),U.pixelStorei(U.UNPACK_SKIP_ROWS,x.min.y),U.pixelStorei(U.UNPACK_SKIP_IMAGES,x.min.z),F.isDataTexture||F.isData3DTexture?U.texSubImage3D(At,I,P.x,P.y,P.z,lt,ft,xt,Mt,Nt,Zt.data):F.isCompressedArrayTexture?(console.warn("THREE.WebGLRenderer.copyTextureToTexture3D: untested support for compressed srcTexture."),U.compressedTexSubImage3D(At,I,P.x,P.y,P.z,lt,ft,xt,Mt,Zt.data)):U.texSubImage3D(At,I,P.x,P.y,P.z,lt,ft,xt,Mt,Nt,Zt),U.pixelStorei(U.UNPACK_ROW_LENGTH,Rt),U.pixelStorei(U.UNPACK_IMAGE_HEIGHT,te),U.pixelStorei(U.UNPACK_SKIP_PIXELS,ye),U.pixelStorei(U.UNPACK_SKIP_ROWS,ae),U.pixelStorei(U.UNPACK_SKIP_IMAGES,Ve),I===0&&O.generateMipmaps&&U.generateMipmap(At),ht.unbindTexture()},this.initTexture=function(x){x.isCubeTexture?S.setTextureCube(x,0):x.isData3DTexture?S.setTexture3D(x,0):x.isDataArrayTexture||x.isCompressedArrayTexture?S.setTexture2DArray(x,0):S.setTexture2D(x,0),ht.unbindTexture()},this.resetState=function(){D=0,R=0,w=null,ht.reset(),Lt.reset()},typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("observe",{detail:this}))}get coordinateSystem(){return je}get outputColorSpace(){return this._outputColorSpace}set outputColorSpace(t){this._outputColorSpace=t;const e=this.getContext();e.drawingBufferColorSpace=t===Yr?"display-p3":"srgb",e.unpackColorSpace=Gt.workingColorSpace===Yi?"display-p3":"srgb"}get outputEncoding(){return console.warn("THREE.WebGLRenderer: Property .outputEncoding has been removed. Use .outputColorSpace instead."),this.outputColorSpace===le?bn:Bs}set outputEncoding(t){console.warn("THREE.WebGLRenderer: Property .outputEncoding has been removed. Use .outputColorSpace instead."),this.outputColorSpace=t===bn?le:Je}get useLegacyLights(){return console.warn("THREE.WebGLRenderer: The property .useLegacyLights has been deprecated. Migrate your lighting according to the following guide: https://discourse.threejs.org/t/updates-to-lighting-in-three-js-r155/53733."),this._useLegacyLights}set useLegacyLights(t){console.warn("THREE.WebGLRenderer: The property .useLegacyLights has been deprecated. Migrate your lighting according to the following guide: https://discourse.threejs.org/t/updates-to-lighting-in-three-js-r155/53733."),this._useLegacyLights=t}}class wf extends lo{}wf.prototype.isWebGL1Renderer=!0;class Rf extends be{constructor(){super(),this.isScene=!0,this.type="Scene",this.background=null,this.environment=null,this.fog=null,this.backgroundBlurriness=0,this.backgroundIntensity=1,this.overrideMaterial=null,typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("observe",{detail:this}))}copy(t,e){return super.copy(t,e),t.background!==null&&(this.background=t.background.clone()),t.environment!==null&&(this.environment=t.environment.clone()),t.fog!==null&&(this.fog=t.fog.clone()),this.backgroundBlurriness=t.backgroundBlurriness,this.backgroundIntensity=t.backgroundIntensity,t.overrideMaterial!==null&&(this.overrideMaterial=t.overrideMaterial.clone()),this.matrixAutoUpdate=t.matrixAutoUpdate,this}toJSON(t){const e=super.toJSON(t);return this.fog!==null&&(e.object.fog=this.fog.toJSON()),this.backgroundBlurriness>0&&(e.object.backgroundBlurriness=this.backgroundBlurriness),this.backgroundIntensity!==1&&(e.object.backgroundIntensity=this.backgroundIntensity),e}}const As={enabled:!1,files:{},add:function(i,t){this.enabled!==!1&&(this.files[i]=t)},get:function(i){if(this.enabled!==!1)return this.files[i]},remove:function(i){delete this.files[i]},clear:function(){this.files={}}};class Cf{constructor(t,e,n){const r=this;let a=!1,o=0,s=0,l;const c=[];this.onStart=void 0,this.onLoad=t,this.onProgress=e,this.onError=n,this.itemStart=function(u){s++,a===!1&&r.onStart!==void 0&&r.onStart(u,o,s),a=!0},this.itemEnd=function(u){o++,r.onProgress!==void 0&&r.onProgress(u,o,s),o===s&&(a=!1,r.onLoad!==void 0&&r.onLoad())},this.itemError=function(u){r.onError!==void 0&&r.onError(u)},this.resolveURL=function(u){return l?l(u):u},this.setURLModifier=function(u){return l=u,this},this.addHandler=function(u,d){return c.push(u,d),this},this.removeHandler=function(u){const d=c.indexOf(u);return d!==-1&&c.splice(d,2),this},this.getHandler=function(u){for(let d=0,f=c.length;d<f;d+=2){const m=c[d],v=c[d+1];if(m.global&&(m.lastIndex=0),m.test(u))return v}return null}}}const Pf=new Cf;class Kr{constructor(t){this.manager=t!==void 0?t:Pf,this.crossOrigin="anonymous",this.withCredentials=!1,this.path="",this.resourcePath="",this.requestHeader={}}load(){}loadAsync(t,e){const n=this;return new Promise(function(r,a){n.load(t,r,e,a)})}parse(){}setCrossOrigin(t){return this.crossOrigin=t,this}setWithCredentials(t){return this.withCredentials=t,this}setPath(t){return this.path=t,this}setResourcePath(t){return this.resourcePath=t,this}setRequestHeader(t){return this.requestHeader=t,this}}Kr.DEFAULT_MATERIAL_NAME="__DEFAULT";class Lf extends Kr{constructor(t){super(t)}load(t,e,n,r){this.path!==void 0&&(t=this.path+t),t=this.manager.resolveURL(t);const a=this,o=As.get(t);if(o!==void 0)return a.manager.itemStart(t),setTimeout(function(){e&&e(o),a.manager.itemEnd(t)},0),o;const s=li("img");function l(){u(),As.add(t,this),e&&e(this),a.manager.itemEnd(t)}function c(d){u(),r&&r(d),a.manager.itemError(t),a.manager.itemEnd(t)}function u(){s.removeEventListener("load",l,!1),s.removeEventListener("error",c,!1)}return s.addEventListener("load",l,!1),s.addEventListener("error",c,!1),t.slice(0,5)!=="data:"&&this.crossOrigin!==void 0&&(s.crossOrigin=this.crossOrigin),a.manager.itemStart(t),s.src=t,s}}class co extends Kr{constructor(t){super(t)}load(t,e,n,r){const a=new Se,o=new Lf(this.manager);return o.setCrossOrigin(this.crossOrigin),o.setPath(this.path),o.load(t,function(s){a.image=s,a.needsUpdate=!0,e!==void 0&&e(a)},n,r),a}}typeof __THREE_DEVTOOLS__<"u"&&__THREE_DEVTOOLS__.dispatchEvent(new CustomEvent("register",{detail:{revision:Xr}}));typeof window<"u"&&(window.__THREE__?console.warn("WARNING: Multiple instances of Three.js being imported."):window.__THREE__=Xr);const Jr=new dn;Jr.setAttribute("position",new Ke([-1,3,0,-1,-1,0,3,-1,0],3));Jr.setAttribute("uv",new Ke([0,2,0,0,2,0],2));const ws={format:Ce,type:$e,wrapS:Ee,wrapT:Ee,minFilter:oe,magFilter:oe,depthBuffer:!1,stencilBuffer:!1};class Dr{constructor(t,e,n={x:window.innerWidth,y:window.innerHeight}){this.res=n,this.renderer=e,this.uniforms=t.uniforms,this.shader=t.shader,this.material=new hn({uniforms:this.uniforms,fragmentShader:this.shader}),this.mesh=new Ze(Jr,this.material),this.scene=new Rf,this.scene.add(this.mesh),this.camera=new eo(-1,1,1,-1,0,1),this.a=new Qe(this.res.x,this.res.y,ws),this.b=new Qe(this.res.x,this.res.y,ws),this.data=null,this.updateUniforms({iResolution:new L(this.res.x,this.res.y,0)})}rtSwap(){let t=this.a;this.a=this.b,this.b=t}render(){this.renderer.setRenderTarget(this.a),this.renderer.render(this.scene,this.camera),this.rtSwap(),this.data=this.b.texture,this.renderer.setRenderTarget(null)}renderToScreen(){this.renderer.setRenderTarget(null),this.renderer.render(this.scene,this.camera)}getData(){return this.data}updateUniforms(t){for(const[e,n]of Object.entries(t))this.material.uniforms[e].value=n}setSize(t){this.res=t,this.a.setSize(t.x,t.y),this.b.setSize(t.x,t.y),this.updateUniforms({iResolution:new L(t.x,t.y,0)})}}class Df{constructor(t){document.addEventListener("keydown",e=>this.down(e)),document.addEventListener("keyup",e=>this.up(e)),this.needsUpdate=!1,this.translateSpeed=.03,this.rotateSpeed=.01,this.translate={right:{key:39,pressed:!1,action:new L(1,0,0).multiplyScalar(this.translateSpeed)},left:{key:37,pressed:!1,action:new L(-1,0,0).multiplyScalar(this.translateSpeed)},up:{key:222,pressed:!1,action:new L(0,1,0).multiplyScalar(this.translateSpeed)},down:{key:191,pressed:!1,action:new L(0,-1,0).multiplyScalar(this.translateSpeed)},forward:{key:38,pressed:!1,action:new L(0,0,-1).multiplyScalar(this.translateSpeed)},backward:{key:40,pressed:!1,action:new L(0,0,1).multiplyScalar(this.translateSpeed)}},this.rotate={right:{key:68,pressed:!1,action:new Kt().makeRotationAxis(new L(0,-1,0),this.rotateSpeed)},left:{key:65,pressed:!1,action:new Kt().makeRotationAxis(new L(0,1,0),this.rotateSpeed)},up:{key:87,pressed:!1,action:new Kt().makeRotationAxis(new L(1,0,0),this.rotateSpeed)},down:{key:83,pressed:!1,action:new Kt().makeRotationAxis(new L(-1,0,0),this.rotateSpeed)},clockwise:{key:69,pressed:!1,action:new Kt().makeRotationAxis(new L(0,0,1),this.rotateSpeed)},counterlockwise:{key:81,pressed:!1,action:new Kt().makeRotationAxis(new L(0,0,-1),this.rotateSpeed)}},this.position=new L(t.position[0],t.position[1],t.position[2]),this.facing=new Ct().set(t.facing[0],t.facing[1],t.facing[2],t.facing[3],t.facing[4],t.facing[5],t.facing[6],t.facing[7],t.facing[8])}down(t){for(const e in this.translate)this.translate[e].key==t.keyCode&&(this.translate[e].pressed=!0,this.needsUpdate=!0);for(const e in this.rotate)this.rotate[e].key==t.keyCode&&(this.rotate[e].pressed=!0,this.needsUpdate=!0)}up(t){for(const e in this.translate)this.translate[e].key==t.keyCode&&(this.translate[e].pressed=!1);for(const e in this.rotate)this.rotate[e].key==t.keyCode&&(this.rotate[e].pressed=!1)}isPressed(){let t=!1;for(const e in this.translate)t=t||this.translate[e].pressed;for(const e in this.rotate)t=t||this.rotate[e].pressed;return t}update(){for(const t in this.translate)if(this.translate[t].pressed){let e=this.translate[t].action.clone();e.applyMatrix3(this.facing),this.position.add(e)}for(const t in this.rotate)this.rotate[t].pressed&&this.facing.multiply(new Ct().setFromMatrix4(this.rotate[t].action))}printLocation(){let t=this.facing.transpose(),e="";return e+=`let position = [${this.position.x},${this.position.y},${this.position.z}];

`,e+=`let facing = [${t.elements}]; 

`,e+=`let location = {
position: position,
facing: facing
};

`,e+="export {location};",e}}class Uf{constructor(t,e,n={x:window.innerWidth,y:window.innerHeight}){this.settings=e,this.renderer=new lo({preserveDrawingBuffer:!0}),this.autoSave=!1,this.autoSaveSPP=1e5,this.autoSavePanels=!1,this.autoSavePanelsSPP=1e5,this.canvas=this.renderer.domElement,document.body.appendChild(this.canvas),this.renderer.setSize(n.x,n.y),this.controls=new Df(this.settings.location),this.tracer=new Dr(t.tracer,this.renderer,n),this.accumulate=new Dr(t.accumulate,this.renderer,n),this.display=new Dr(t.display,this.renderer,n)}updateUniforms(){this.tracer.material.uniforms.frameNumber.value+=1,this.accumulate.material.uniforms.frameNumber.value+=1,this.controls.isPressed()&&(this.controls.update(),this.tracer.updateUniforms({facing:this.controls.facing,location:this.controls.position}),this.reset())}newFrame(){this.updateUniforms(),this.tracer.render(),this.accumulate.updateUniforms({newTex:this.tracer.getData()}),this.accumulate.render(),this.accumulate.updateUniforms({accTex:this.accumulate.getData()}),this.display.updateUniforms({accTex:this.accumulate.getData()}),this.display.renderToScreen(),this.autoSave&&this.tracer.material.uniforms.frameNumber.value%this.autoSaveSPP==0&&this.saveImage(),this.autoSavePanels&&this.tracer.material.uniforms.panelToRender.value<this.tracer.material.uniforms.numPanels.value&&this.tracer.material.uniforms.frameNumber.value==this.autoSavePanelsSPP&&(this.saveImage(),this.tracer.material.uniforms.panelToRender.value+=1,this.reset())}reset(){this.tracer.updateUniforms({frameNumber:0}),this.accumulate.updateUniforms({frameNumber:0})}saveImage(){const t=new Date;let e=t.getDate(),n=t.getMonth()+1,r=t.getHours(),a=t.getMinutes(),o=this.canvas,s=document.createElement("a");s.download=`${this.tracer.material.uniforms.frameNumber.value}spp pathtrace ${n}-${e}-${r}${a}.png`,s.href=o.toDataURL("image/png"),s.click()}resize(t){this.tracer.setSize(t),this.accumulate.setSize(t),this.display.setSize(t),this.renderer.setSize(t.x,t.y)}printLocation(){return this.controls.printLocation()}}/**
 * lil-gui
 * https://lil-gui.georgealways.com
 * @version 0.17.0
 * @author George Michael Brower
 * @license MIT
 */class Be{constructor(t,e,n,r,a="div"){this.parent=t,this.object=e,this.property=n,this._disabled=!1,this._hidden=!1,this.initialValue=this.getValue(),this.domElement=document.createElement("div"),this.domElement.classList.add("controller"),this.domElement.classList.add(r),this.$name=document.createElement("div"),this.$name.classList.add("name"),Be.nextNameID=Be.nextNameID||0,this.$name.id="lil-gui-name-"+ ++Be.nextNameID,this.$widget=document.createElement(a),this.$widget.classList.add("widget"),this.$disable=this.$widget,this.domElement.appendChild(this.$name),this.domElement.appendChild(this.$widget),this.parent.children.push(this),this.parent.controllers.push(this),this.parent.$children.appendChild(this.domElement),this._listenCallback=this._listenCallback.bind(this),this.name(n)}name(t){return this._name=t,this.$name.innerHTML=t,this}onChange(t){return this._onChange=t,this}_callOnChange(){this.parent._callOnChange(this),this._onChange!==void 0&&this._onChange.call(this,this.getValue()),this._changed=!0}onFinishChange(t){return this._onFinishChange=t,this}_callOnFinishChange(){this._changed&&(this.parent._callOnFinishChange(this),this._onFinishChange!==void 0&&this._onFinishChange.call(this,this.getValue())),this._changed=!1}reset(){return this.setValue(this.initialValue),this._callOnFinishChange(),this}enable(t=!0){return this.disable(!t)}disable(t=!0){return t===this._disabled||(this._disabled=t,this.domElement.classList.toggle("disabled",t),this.$disable.toggleAttribute("disabled",t)),this}show(t=!0){return this._hidden=!t,this.domElement.style.display=this._hidden?"none":"",this}hide(){return this.show(!1)}options(t){const e=this.parent.add(this.object,this.property,t);return e.name(this._name),this.destroy(),e}min(t){return this}max(t){return this}step(t){return this}decimals(t){return this}listen(t=!0){return this._listening=t,this._listenCallbackID!==void 0&&(cancelAnimationFrame(this._listenCallbackID),this._listenCallbackID=void 0),this._listening&&this._listenCallback(),this}_listenCallback(){this._listenCallbackID=requestAnimationFrame(this._listenCallback);const t=this.save();t!==this._listenPrevValue&&this.updateDisplay(),this._listenPrevValue=t}getValue(){return this.object[this.property]}setValue(t){return this.object[this.property]=t,this._callOnChange(),this.updateDisplay(),this}updateDisplay(){return this}load(t){return this.setValue(t),this._callOnFinishChange(),this}save(){return this.getValue()}destroy(){this.listen(!1),this.parent.children.splice(this.parent.children.indexOf(this),1),this.parent.controllers.splice(this.parent.controllers.indexOf(this),1),this.parent.$children.removeChild(this.domElement)}}class If extends Be{constructor(t,e,n){super(t,e,n,"boolean","label"),this.$input=document.createElement("input"),this.$input.setAttribute("type","checkbox"),this.$input.setAttribute("aria-labelledby",this.$name.id),this.$widget.appendChild(this.$input),this.$input.addEventListener("change",()=>{this.setValue(this.$input.checked),this._callOnFinishChange()}),this.$disable=this.$input,this.updateDisplay()}updateDisplay(){return this.$input.checked=this.getValue(),this}}function Wr(i){let t,e;return(t=i.match(/(#|0x)?([a-f0-9]{6})/i))?e=t[2]:(t=i.match(/rgb\(\s*(\d*)\s*,\s*(\d*)\s*,\s*(\d*)\s*\)/))?e=parseInt(t[1]).toString(16).padStart(2,0)+parseInt(t[2]).toString(16).padStart(2,0)+parseInt(t[3]).toString(16).padStart(2,0):(t=i.match(/^#?([a-f0-9])([a-f0-9])([a-f0-9])$/i))&&(e=t[1]+t[1]+t[2]+t[2]+t[3]+t[3]),!!e&&"#"+e}const Nf={isPrimitive:!0,match:i=>typeof i=="string",fromHexString:Wr,toHexString:Wr},ci={isPrimitive:!0,match:i=>typeof i=="number",fromHexString:i=>parseInt(i.substring(1),16),toHexString:i=>"#"+i.toString(16).padStart(6,0)},Ff={isPrimitive:!1,match:Array.isArray,fromHexString(i,t,e=1){const n=ci.fromHexString(i);t[0]=(n>>16&255)/255*e,t[1]=(n>>8&255)/255*e,t[2]=(255&n)/255*e},toHexString:([i,t,e],n=1)=>ci.toHexString(i*(n=255/n)<<16^t*n<<8^e*n<<0)},Of={isPrimitive:!1,match:i=>Object(i)===i,fromHexString(i,t,e=1){const n=ci.fromHexString(i);t.r=(n>>16&255)/255*e,t.g=(n>>8&255)/255*e,t.b=(255&n)/255*e},toHexString:({r:i,g:t,b:e},n=1)=>ci.toHexString(i*(n=255/n)<<16^t*n<<8^e*n<<0)},zf=[Nf,ci,Ff,Of];class Bf extends Be{constructor(t,e,n,r){var a;super(t,e,n,"color"),this.$input=document.createElement("input"),this.$input.setAttribute("type","color"),this.$input.setAttribute("tabindex",-1),this.$input.setAttribute("aria-labelledby",this.$name.id),this.$text=document.createElement("input"),this.$text.setAttribute("type","text"),this.$text.setAttribute("spellcheck","false"),this.$text.setAttribute("aria-labelledby",this.$name.id),this.$display=document.createElement("div"),this.$display.classList.add("display"),this.$display.appendChild(this.$input),this.$widget.appendChild(this.$display),this.$widget.appendChild(this.$text),this._format=(a=this.initialValue,zf.find(o=>o.match(a))),this._rgbScale=r,this._initialValueHexString=this.save(),this._textFocused=!1,this.$input.addEventListener("input",()=>{this._setValueFromHexString(this.$input.value)}),this.$input.addEventListener("blur",()=>{this._callOnFinishChange()}),this.$text.addEventListener("input",()=>{const o=Wr(this.$text.value);o&&this._setValueFromHexString(o)}),this.$text.addEventListener("focus",()=>{this._textFocused=!0,this.$text.select()}),this.$text.addEventListener("blur",()=>{this._textFocused=!1,this.updateDisplay(),this._callOnFinishChange()}),this.$disable=this.$text,this.updateDisplay()}reset(){return this._setValueFromHexString(this._initialValueHexString),this}_setValueFromHexString(t){if(this._format.isPrimitive){const e=this._format.fromHexString(t);this.setValue(e)}else this._format.fromHexString(t,this.getValue(),this._rgbScale),this._callOnChange(),this.updateDisplay()}save(){return this._format.toHexString(this.getValue(),this._rgbScale)}load(t){return this._setValueFromHexString(t),this._callOnFinishChange(),this}updateDisplay(){return this.$input.value=this._format.toHexString(this.getValue(),this._rgbScale),this._textFocused||(this.$text.value=this.$input.value.substring(1)),this.$display.style.backgroundColor=this.$input.value,this}}class Ur extends Be{constructor(t,e,n){super(t,e,n,"function"),this.$button=document.createElement("button"),this.$button.appendChild(this.$name),this.$widget.appendChild(this.$button),this.$button.addEventListener("click",r=>{r.preventDefault(),this.getValue().call(this.object)}),this.$button.addEventListener("touchstart",()=>{},{passive:!0}),this.$disable=this.$button}}class Vf extends Be{constructor(t,e,n,r,a,o){super(t,e,n,"number"),this._initInput(),this.min(r),this.max(a);const s=o!==void 0;this.step(s?o:this._getImplicitStep(),s),this.updateDisplay()}decimals(t){return this._decimals=t,this.updateDisplay(),this}min(t){return this._min=t,this._onUpdateMinMax(),this}max(t){return this._max=t,this._onUpdateMinMax(),this}step(t,e=!0){return this._step=t,this._stepExplicit=e,this}updateDisplay(){const t=this.getValue();if(this._hasSlider){let e=(t-this._min)/(this._max-this._min);e=Math.max(0,Math.min(e,1)),this.$fill.style.width=100*e+"%"}return this._inputFocused||(this.$input.value=this._decimals===void 0?t:t.toFixed(this._decimals)),this}_initInput(){this.$input=document.createElement("input"),this.$input.setAttribute("type","number"),this.$input.setAttribute("step","any"),this.$input.setAttribute("aria-labelledby",this.$name.id),this.$widget.appendChild(this.$input),this.$disable=this.$input;const t=u=>{const d=parseFloat(this.$input.value);isNaN(d)||(this._snapClampSetValue(d+u),this.$input.value=this.getValue())};let e,n,r,a,o,s=!1;const l=u=>{if(s){const d=u.clientX-e,f=u.clientY-n;Math.abs(f)>5?(u.preventDefault(),this.$input.blur(),s=!1,this._setDraggingStyle(!0,"vertical")):Math.abs(d)>5&&c()}if(!s){const d=u.clientY-r;o-=d*this._step*this._arrowKeyMultiplier(u),a+o>this._max?o=this._max-a:a+o<this._min&&(o=this._min-a),this._snapClampSetValue(a+o)}r=u.clientY},c=()=>{this._setDraggingStyle(!1,"vertical"),this._callOnFinishChange(),window.removeEventListener("mousemove",l),window.removeEventListener("mouseup",c)};this.$input.addEventListener("input",()=>{let u=parseFloat(this.$input.value);isNaN(u)||(this._stepExplicit&&(u=this._snap(u)),this.setValue(this._clamp(u)))}),this.$input.addEventListener("keydown",u=>{u.code==="Enter"&&this.$input.blur(),u.code==="ArrowUp"&&(u.preventDefault(),t(this._step*this._arrowKeyMultiplier(u))),u.code==="ArrowDown"&&(u.preventDefault(),t(this._step*this._arrowKeyMultiplier(u)*-1))}),this.$input.addEventListener("wheel",u=>{this._inputFocused&&(u.preventDefault(),t(this._step*this._normalizeMouseWheel(u)))},{passive:!1}),this.$input.addEventListener("mousedown",u=>{e=u.clientX,n=r=u.clientY,s=!0,a=this.getValue(),o=0,window.addEventListener("mousemove",l),window.addEventListener("mouseup",c)}),this.$input.addEventListener("focus",()=>{this._inputFocused=!0}),this.$input.addEventListener("blur",()=>{this._inputFocused=!1,this.updateDisplay(),this._callOnFinishChange()})}_initSlider(){this._hasSlider=!0,this.$slider=document.createElement("div"),this.$slider.classList.add("slider"),this.$fill=document.createElement("div"),this.$fill.classList.add("fill"),this.$slider.appendChild(this.$fill),this.$widget.insertBefore(this.$slider,this.$input),this.domElement.classList.add("hasSlider");const t=f=>{const m=this.$slider.getBoundingClientRect();let v=(_=f,p=m.left,h=m.right,E=this._min,T=this._max,(_-p)/(h-p)*(T-E)+E);var _,p,h,E,T;this._snapClampSetValue(v)},e=f=>{t(f.clientX)},n=()=>{this._callOnFinishChange(),this._setDraggingStyle(!1),window.removeEventListener("mousemove",e),window.removeEventListener("mouseup",n)};let r,a,o=!1;const s=f=>{f.preventDefault(),this._setDraggingStyle(!0),t(f.touches[0].clientX),o=!1},l=f=>{if(o){const m=f.touches[0].clientX-r,v=f.touches[0].clientY-a;Math.abs(m)>Math.abs(v)?s(f):(window.removeEventListener("touchmove",l),window.removeEventListener("touchend",c))}else f.preventDefault(),t(f.touches[0].clientX)},c=()=>{this._callOnFinishChange(),this._setDraggingStyle(!1),window.removeEventListener("touchmove",l),window.removeEventListener("touchend",c)},u=this._callOnFinishChange.bind(this);let d;this.$slider.addEventListener("mousedown",f=>{this._setDraggingStyle(!0),t(f.clientX),window.addEventListener("mousemove",e),window.addEventListener("mouseup",n)}),this.$slider.addEventListener("touchstart",f=>{f.touches.length>1||(this._hasScrollBar?(r=f.touches[0].clientX,a=f.touches[0].clientY,o=!0):s(f),window.addEventListener("touchmove",l,{passive:!1}),window.addEventListener("touchend",c))},{passive:!1}),this.$slider.addEventListener("wheel",f=>{if(Math.abs(f.deltaX)<Math.abs(f.deltaY)&&this._hasScrollBar)return;f.preventDefault();const m=this._normalizeMouseWheel(f)*this._step;this._snapClampSetValue(this.getValue()+m),this.$input.value=this.getValue(),clearTimeout(d),d=setTimeout(u,400)},{passive:!1})}_setDraggingStyle(t,e="horizontal"){this.$slider&&this.$slider.classList.toggle("active",t),document.body.classList.toggle("lil-gui-dragging",t),document.body.classList.toggle("lil-gui-"+e,t)}_getImplicitStep(){return this._hasMin&&this._hasMax?(this._max-this._min)/1e3:.1}_onUpdateMinMax(){!this._hasSlider&&this._hasMin&&this._hasMax&&(this._stepExplicit||this.step(this._getImplicitStep(),!1),this._initSlider(),this.updateDisplay())}_normalizeMouseWheel(t){let{deltaX:e,deltaY:n}=t;return Math.floor(t.deltaY)!==t.deltaY&&t.wheelDelta&&(e=0,n=-t.wheelDelta/120,n*=this._stepExplicit?1:10),e+-n}_arrowKeyMultiplier(t){let e=this._stepExplicit?1:10;return t.shiftKey?e*=10:t.altKey&&(e/=10),e}_snap(t){const e=Math.round(t/this._step)*this._step;return parseFloat(e.toPrecision(15))}_clamp(t){return t<this._min&&(t=this._min),t>this._max&&(t=this._max),t}_snapClampSetValue(t){this.setValue(this._clamp(this._snap(t)))}get _hasScrollBar(){const t=this.parent.root.$children;return t.scrollHeight>t.clientHeight}get _hasMin(){return this._min!==void 0}get _hasMax(){return this._max!==void 0}}class Hf extends Be{constructor(t,e,n,r){super(t,e,n,"option"),this.$select=document.createElement("select"),this.$select.setAttribute("aria-labelledby",this.$name.id),this.$display=document.createElement("div"),this.$display.classList.add("display"),this._values=Array.isArray(r)?r:Object.values(r),this._names=Array.isArray(r)?r:Object.keys(r),this._names.forEach(a=>{const o=document.createElement("option");o.innerHTML=a,this.$select.appendChild(o)}),this.$select.addEventListener("change",()=>{this.setValue(this._values[this.$select.selectedIndex]),this._callOnFinishChange()}),this.$select.addEventListener("focus",()=>{this.$display.classList.add("focus")}),this.$select.addEventListener("blur",()=>{this.$display.classList.remove("focus")}),this.$widget.appendChild(this.$select),this.$widget.appendChild(this.$display),this.$disable=this.$select,this.updateDisplay()}updateDisplay(){const t=this.getValue(),e=this._values.indexOf(t);return this.$select.selectedIndex=e,this.$display.innerHTML=e===-1?t:this._names[e],this}}class Gf extends Be{constructor(t,e,n){super(t,e,n,"string"),this.$input=document.createElement("input"),this.$input.setAttribute("type","text"),this.$input.setAttribute("aria-labelledby",this.$name.id),this.$input.addEventListener("input",()=>{this.setValue(this.$input.value)}),this.$input.addEventListener("keydown",r=>{r.code==="Enter"&&this.$input.blur()}),this.$input.addEventListener("blur",()=>{this._callOnFinishChange()}),this.$widget.appendChild(this.$input),this.$disable=this.$input,this.updateDisplay()}updateDisplay(){return this.$input.value=this.getValue(),this}}let Rs=!1;class Qr{constructor({parent:t,autoPlace:e=t===void 0,container:n,width:r,title:a="Controls",injectStyles:o=!0,touchStyles:s=!0}={}){if(this.parent=t,this.root=t?t.root:this,this.children=[],this.controllers=[],this.folders=[],this._closed=!1,this._hidden=!1,this.domElement=document.createElement("div"),this.domElement.classList.add("lil-gui"),this.$title=document.createElement("div"),this.$title.classList.add("title"),this.$title.setAttribute("role","button"),this.$title.setAttribute("aria-expanded",!0),this.$title.setAttribute("tabindex",0),this.$title.addEventListener("click",()=>this.openAnimated(this._closed)),this.$title.addEventListener("keydown",l=>{l.code!=="Enter"&&l.code!=="Space"||(l.preventDefault(),this.$title.click())}),this.$title.addEventListener("touchstart",()=>{},{passive:!0}),this.$children=document.createElement("div"),this.$children.classList.add("children"),this.domElement.appendChild(this.$title),this.domElement.appendChild(this.$children),this.title(a),s&&this.domElement.classList.add("allow-touch-styles"),this.parent)return this.parent.children.push(this),this.parent.folders.push(this),void this.parent.$children.appendChild(this.domElement);this.domElement.classList.add("root"),!Rs&&o&&(function(l){const c=document.createElement("style");c.innerHTML=l;const u=document.querySelector("head link[rel=stylesheet], head style");u?document.head.insertBefore(c,u):document.head.appendChild(c)}('.lil-gui{--background-color:#1f1f1f;--text-color:#ebebeb;--title-background-color:#111;--title-text-color:#ebebeb;--widget-color:#424242;--hover-color:#4f4f4f;--focus-color:#595959;--number-color:#2cc9ff;--string-color:#a2db3c;--font-size:11px;--input-font-size:11px;--font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Arial,sans-serif;--font-family-mono:Menlo,Monaco,Consolas,"Droid Sans Mono",monospace;--padding:4px;--spacing:4px;--widget-height:20px;--name-width:45%;--slider-knob-width:2px;--slider-input-width:27%;--color-input-width:27%;--slider-input-min-width:45px;--color-input-min-width:45px;--folder-indent:7px;--widget-padding:0 0 0 3px;--widget-border-radius:2px;--checkbox-size:calc(var(--widget-height)*0.75);--scrollbar-width:5px;background-color:var(--background-color);color:var(--text-color);font-family:var(--font-family);font-size:var(--font-size);font-style:normal;font-weight:400;line-height:1;text-align:left;touch-action:manipulation;user-select:none;-webkit-user-select:none}.lil-gui,.lil-gui *{box-sizing:border-box;margin:0;padding:0}.lil-gui.root{display:flex;flex-direction:column;width:var(--width,245px)}.lil-gui.root>.title{background:var(--title-background-color);color:var(--title-text-color)}.lil-gui.root>.children{overflow-x:hidden;overflow-y:auto}.lil-gui.root>.children::-webkit-scrollbar{background:var(--background-color);height:var(--scrollbar-width);width:var(--scrollbar-width)}.lil-gui.root>.children::-webkit-scrollbar-thumb{background:var(--focus-color);border-radius:var(--scrollbar-width)}.lil-gui.force-touch-styles{--widget-height:28px;--padding:6px;--spacing:6px;--font-size:13px;--input-font-size:16px;--folder-indent:10px;--scrollbar-width:7px;--slider-input-min-width:50px;--color-input-min-width:65px}.lil-gui.autoPlace{max-height:100%;position:fixed;right:15px;top:0;z-index:1001}.lil-gui .controller{align-items:center;display:flex;margin:var(--spacing) 0;padding:0 var(--padding)}.lil-gui .controller.disabled{opacity:.5}.lil-gui .controller.disabled,.lil-gui .controller.disabled *{pointer-events:none!important}.lil-gui .controller>.name{flex-shrink:0;line-height:var(--widget-height);min-width:var(--name-width);padding-right:var(--spacing);white-space:pre}.lil-gui .controller .widget{align-items:center;display:flex;min-height:var(--widget-height);position:relative;width:100%}.lil-gui .controller.string input{color:var(--string-color)}.lil-gui .controller.boolean .widget{cursor:pointer}.lil-gui .controller.color .display{border-radius:var(--widget-border-radius);height:var(--widget-height);position:relative;width:100%}.lil-gui .controller.color input[type=color]{cursor:pointer;height:100%;opacity:0;width:100%}.lil-gui .controller.color input[type=text]{flex-shrink:0;font-family:var(--font-family-mono);margin-left:var(--spacing);min-width:var(--color-input-min-width);width:var(--color-input-width)}.lil-gui .controller.option select{max-width:100%;opacity:0;position:absolute;width:100%}.lil-gui .controller.option .display{background:var(--widget-color);border-radius:var(--widget-border-radius);height:var(--widget-height);line-height:var(--widget-height);max-width:100%;overflow:hidden;padding-left:.55em;padding-right:1.75em;pointer-events:none;position:relative;word-break:break-all}.lil-gui .controller.option .display.active{background:var(--focus-color)}.lil-gui .controller.option .display:after{bottom:0;content:"↕";font-family:lil-gui;padding-right:.375em;position:absolute;right:0;top:0}.lil-gui .controller.option .widget,.lil-gui .controller.option select{cursor:pointer}.lil-gui .controller.number input{color:var(--number-color)}.lil-gui .controller.number.hasSlider input{flex-shrink:0;margin-left:var(--spacing);min-width:var(--slider-input-min-width);width:var(--slider-input-width)}.lil-gui .controller.number .slider{background-color:var(--widget-color);border-radius:var(--widget-border-radius);cursor:ew-resize;height:var(--widget-height);overflow:hidden;padding-right:var(--slider-knob-width);touch-action:pan-y;width:100%}.lil-gui .controller.number .slider.active{background-color:var(--focus-color)}.lil-gui .controller.number .slider.active .fill{opacity:.95}.lil-gui .controller.number .fill{border-right:var(--slider-knob-width) solid var(--number-color);box-sizing:content-box;height:100%}.lil-gui-dragging .lil-gui{--hover-color:var(--widget-color)}.lil-gui-dragging *{cursor:ew-resize!important}.lil-gui-dragging.lil-gui-vertical *{cursor:ns-resize!important}.lil-gui .title{--title-height:calc(var(--widget-height) + var(--spacing)*1.25);-webkit-tap-highlight-color:transparent;text-decoration-skip:objects;cursor:pointer;font-weight:600;height:var(--title-height);line-height:calc(var(--title-height) - 4px);outline:none;padding:0 var(--padding)}.lil-gui .title:before{content:"▾";display:inline-block;font-family:lil-gui;padding-right:2px}.lil-gui .title:active{background:var(--title-background-color);opacity:.75}.lil-gui.root>.title:focus{text-decoration:none!important}.lil-gui.closed>.title:before{content:"▸"}.lil-gui.closed>.children{opacity:0;transform:translateY(-7px)}.lil-gui.closed:not(.transition)>.children{display:none}.lil-gui.transition>.children{overflow:hidden;pointer-events:none;transition-duration:.3s;transition-property:height,opacity,transform;transition-timing-function:cubic-bezier(.2,.6,.35,1)}.lil-gui .children:empty:before{content:"Empty";display:block;font-style:italic;height:var(--widget-height);line-height:var(--widget-height);margin:var(--spacing) 0;opacity:.5;padding:0 var(--padding)}.lil-gui.root>.children>.lil-gui>.title{border-width:0;border-bottom:1px solid var(--widget-color);border-left:0 solid var(--widget-color);border-right:0 solid var(--widget-color);border-top:1px solid var(--widget-color);transition:border-color .3s}.lil-gui.root>.children>.lil-gui.closed>.title{border-bottom-color:transparent}.lil-gui+.controller{border-top:1px solid var(--widget-color);margin-top:0;padding-top:var(--spacing)}.lil-gui .lil-gui .lil-gui>.title{border:none}.lil-gui .lil-gui .lil-gui>.children{border:none;border-left:2px solid var(--widget-color);margin-left:var(--folder-indent)}.lil-gui .lil-gui .controller{border:none}.lil-gui input{-webkit-tap-highlight-color:transparent;background:var(--widget-color);border:0;border-radius:var(--widget-border-radius);color:var(--text-color);font-family:var(--font-family);font-size:var(--input-font-size);height:var(--widget-height);outline:none;width:100%}.lil-gui input:disabled{opacity:1}.lil-gui input[type=number],.lil-gui input[type=text]{padding:var(--widget-padding)}.lil-gui input[type=number]:focus,.lil-gui input[type=text]:focus{background:var(--focus-color)}.lil-gui input::-webkit-inner-spin-button,.lil-gui input::-webkit-outer-spin-button{-webkit-appearance:none;margin:0}.lil-gui input[type=number]{-moz-appearance:textfield}.lil-gui input[type=checkbox]{appearance:none;-webkit-appearance:none;border-radius:var(--widget-border-radius);cursor:pointer;height:var(--checkbox-size);text-align:center;width:var(--checkbox-size)}.lil-gui input[type=checkbox]:checked:before{content:"✓";font-family:lil-gui;font-size:var(--checkbox-size);line-height:var(--checkbox-size)}.lil-gui button{-webkit-tap-highlight-color:transparent;background:var(--widget-color);border:1px solid var(--widget-color);border-radius:var(--widget-border-radius);color:var(--text-color);cursor:pointer;font-family:var(--font-family);font-size:var(--font-size);height:var(--widget-height);line-height:calc(var(--widget-height) - 4px);outline:none;text-align:center;text-transform:none;width:100%}.lil-gui button:active{background:var(--focus-color)}@font-face{font-family:lil-gui;src:url("data:application/font-woff;charset=utf-8;base64,d09GRgABAAAAAAUsAAsAAAAACJwAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAABHU1VCAAABCAAAAH4AAADAImwmYE9TLzIAAAGIAAAAPwAAAGBKqH5SY21hcAAAAcgAAAD0AAACrukyyJBnbHlmAAACvAAAAF8AAACEIZpWH2hlYWQAAAMcAAAAJwAAADZfcj2zaGhlYQAAA0QAAAAYAAAAJAC5AHhobXR4AAADXAAAABAAAABMAZAAAGxvY2EAAANsAAAAFAAAACgCEgIybWF4cAAAA4AAAAAeAAAAIAEfABJuYW1lAAADoAAAASIAAAIK9SUU/XBvc3QAAATEAAAAZgAAAJCTcMc2eJxVjbEOgjAURU+hFRBK1dGRL+ALnAiToyMLEzFpnPz/eAshwSa97517c/MwwJmeB9kwPl+0cf5+uGPZXsqPu4nvZabcSZldZ6kfyWnomFY/eScKqZNWupKJO6kXN3K9uCVoL7iInPr1X5baXs3tjuMqCtzEuagm/AAlzQgPAAB4nGNgYRBlnMDAysDAYM/gBiT5oLQBAwuDJAMDEwMrMwNWEJDmmsJwgCFeXZghBcjlZMgFCzOiKOIFAB71Bb8AeJy1kjFuwkAQRZ+DwRAwBtNQRUGKQ8OdKCAWUhAgKLhIuAsVSpWz5Bbkj3dEgYiUIszqWdpZe+Z7/wB1oCYmIoboiwiLT2WjKl/jscrHfGg/pKdMkyklC5Zs2LEfHYpjcRoPzme9MWWmk3dWbK9ObkWkikOetJ554fWyoEsmdSlt+uR0pCJR34b6t/TVg1SY3sYvdf8vuiKrpyaDXDISiegp17p7579Gp3p++y7HPAiY9pmTibljrr85qSidtlg4+l25GLCaS8e6rRxNBmsnERunKbaOObRz7N72ju5vdAjYpBXHgJylOAVsMseDAPEP8LYoUHicY2BiAAEfhiAGJgZWBgZ7RnFRdnVJELCQlBSRlATJMoLV2DK4glSYs6ubq5vbKrJLSbGrgEmovDuDJVhe3VzcXFwNLCOILB/C4IuQ1xTn5FPilBTj5FPmBAB4WwoqAHicY2BkYGAA4sk1sR/j+W2+MnAzpDBgAyEMQUCSg4EJxAEAwUgFHgB4nGNgZGBgSGFggJMhDIwMqEAYAByHATJ4nGNgAIIUNEwmAABl3AGReJxjYAACIQYlBiMGJ3wQAEcQBEV4nGNgZGBgEGZgY2BiAAEQyQWEDAz/wXwGAAsPATIAAHicXdBNSsNAHAXwl35iA0UQXYnMShfS9GPZA7T7LgIu03SSpkwzYTIt1BN4Ak/gKTyAeCxfw39jZkjymzcvAwmAW/wgwHUEGDb36+jQQ3GXGot79L24jxCP4gHzF/EIr4jEIe7wxhOC3g2TMYy4Q7+Lu/SHuEd/ivt4wJd4wPxbPEKMX3GI5+DJFGaSn4qNzk8mcbKSR6xdXdhSzaOZJGtdapd4vVPbi6rP+cL7TGXOHtXKll4bY1Xl7EGnPtp7Xy2n00zyKLVHfkHBa4IcJ2oD3cgggWvt/V/FbDrUlEUJhTn/0azVWbNTNr0Ens8de1tceK9xZmfB1CPjOmPH4kitmvOubcNpmVTN3oFJyjzCvnmrwhJTzqzVj9jiSX911FjeAAB4nG3HMRKCMBBA0f0giiKi4DU8k0V2GWbIZDOh4PoWWvq6J5V8If9NVNQcaDhyouXMhY4rPTcG7jwYmXhKq8Wz+p762aNaeYXom2n3m2dLTVgsrCgFJ7OTmIkYbwIbC6vIB7WmFfAAAA==") format("woff")}@media (pointer:coarse){.lil-gui.allow-touch-styles{--widget-height:28px;--padding:6px;--spacing:6px;--font-size:13px;--input-font-size:16px;--folder-indent:10px;--scrollbar-width:7px;--slider-input-min-width:50px;--color-input-min-width:65px}}@media (hover:hover){.lil-gui .controller.color .display:hover:before{border:1px solid #fff9;border-radius:var(--widget-border-radius);bottom:0;content:" ";display:block;left:0;position:absolute;right:0;top:0}.lil-gui .controller.option .display.focus{background:var(--focus-color)}.lil-gui .controller.option .widget:hover .display{background:var(--hover-color)}.lil-gui .controller.number .slider:hover{background-color:var(--hover-color)}body:not(.lil-gui-dragging) .lil-gui .title:hover{background:var(--title-background-color);opacity:.85}.lil-gui .title:focus{text-decoration:underline var(--focus-color)}.lil-gui input:hover{background:var(--hover-color)}.lil-gui input:active{background:var(--focus-color)}.lil-gui input[type=checkbox]:focus{box-shadow:inset 0 0 0 1px var(--focus-color)}.lil-gui button:hover{background:var(--hover-color);border-color:var(--hover-color)}.lil-gui button:focus{border-color:var(--focus-color)}}'),Rs=!0),n?n.appendChild(this.domElement):e&&(this.domElement.classList.add("autoPlace"),document.body.appendChild(this.domElement)),r&&this.domElement.style.setProperty("--width",r+"px"),this.domElement.addEventListener("keydown",l=>l.stopPropagation()),this.domElement.addEventListener("keyup",l=>l.stopPropagation())}add(t,e,n,r,a){if(Object(n)===n)return new Hf(this,t,e,n);const o=t[e];switch(typeof o){case"number":return new Vf(this,t,e,n,r,a);case"boolean":return new If(this,t,e);case"string":return new Gf(this,t,e);case"function":return new Ur(this,t,e)}console.error(`gui.add failed
	property:`,e,`
	object:`,t,`
	value:`,o)}addColor(t,e,n=1){return new Bf(this,t,e,n)}addFolder(t){return new Qr({parent:this,title:t})}load(t,e=!0){return t.controllers&&this.controllers.forEach(n=>{n instanceof Ur||n._name in t.controllers&&n.load(t.controllers[n._name])}),e&&t.folders&&this.folders.forEach(n=>{n._title in t.folders&&n.load(t.folders[n._title])}),this}save(t=!0){const e={controllers:{},folders:{}};return this.controllers.forEach(n=>{if(!(n instanceof Ur)){if(n._name in e.controllers)throw new Error(`Cannot save GUI with duplicate property "${n._name}"`);e.controllers[n._name]=n.save()}}),t&&this.folders.forEach(n=>{if(n._title in e.folders)throw new Error(`Cannot save GUI with duplicate folder "${n._title}"`);e.folders[n._title]=n.save()}),e}open(t=!0){return this._closed=!t,this.$title.setAttribute("aria-expanded",!this._closed),this.domElement.classList.toggle("closed",this._closed),this}close(){return this.open(!1)}show(t=!0){return this._hidden=!t,this.domElement.style.display=this._hidden?"none":"",this}hide(){return this.show(!1)}openAnimated(t=!0){return this._closed=!t,this.$title.setAttribute("aria-expanded",!this._closed),requestAnimationFrame(()=>{const e=this.$children.clientHeight;this.$children.style.height=e+"px",this.domElement.classList.add("transition");const n=a=>{a.target===this.$children&&(this.$children.style.height="",this.domElement.classList.remove("transition"),this.$children.removeEventListener("transitionend",n))};this.$children.addEventListener("transitionend",n);const r=t?this.$children.scrollHeight:0;this.domElement.classList.toggle("closed",!t),requestAnimationFrame(()=>{this.$children.style.height=r+"px"})}),this}title(t){return this._title=t,this.$title.innerHTML=t,this}reset(t=!0){return(t?this.controllersRecursive():this.controllers).forEach(e=>e.reset()),this}onChange(t){return this._onChange=t,this}_callOnChange(t){this.parent&&this.parent._callOnChange(t),this._onChange!==void 0&&this._onChange.call(this,{object:t.object,property:t.property,value:t.getValue(),controller:t})}onFinishChange(t){return this._onFinishChange=t,this}_callOnFinishChange(t){this.parent&&this.parent._callOnFinishChange(t),this._onFinishChange!==void 0&&this._onFinishChange.call(this,{object:t.object,property:t.property,value:t.getValue(),controller:t})}destroy(){this.parent&&(this.parent.children.splice(this.parent.children.indexOf(this),1),this.parent.folders.splice(this.parent.folders.indexOf(this),1)),this.domElement.parentElement&&this.domElement.parentElement.removeChild(this.domElement),Array.from(this.children).forEach(t=>t.destroy())}controllersRecursive(){let t=Array.from(this.controllers);return this.folders.forEach(e=>{t=t.concat(e.controllersRecursive())}),t}foldersRecursive(){let t=Array.from(this.folders);return this.folders.forEach(e=>{t=t.concat(e.foldersRecursive())}),t}}class kf extends Qr{constructor(t){super(),this.params={aperture:t.settings.uiParams.aperture,focalLength:t.settings.uiParams.focalLength,exposure:t.settings.uiParams.exposure,focusHelp:!1,fov:t.settings.uiParams.fov,extra:t.settings.uiParams.extra,extra2:t.settings.uiParams.extra2,extra3:t.settings.uiParams.extra3,extra4:t.settings.uiParams.extra4,preview:!1,resize:()=>t.resize({x:window.innerWidth,y:window.innerHeight}),autoSave:!1,autoSavePanels:!1,renderPanel:!1,autoSaveSPP:t.autoSaveSPP,autoSavePanelsSPP:t.autoSavePanelsSPP,numPanels:1,panelToRender:0,panelWidth:window.innerWidth,panelHeight:window.innerHeight,saveit:()=>t.saveImage(),printSettings:()=>{let l="";l+=this.printParams(),l+=`


`,l+=t.printLocation(),l+=`

`,l+="export default {uiParams: uiParams, location:location};";const c=new File([l],"settingsNew.js",{type:"javascript"});function u(){const d=document.createElement("a"),f=URL.createObjectURL(c);d.href=f,d.download=c.name,document.body.appendChild(d),d.click(),document.body.removeChild(d),window.URL.revokeObjectURL(f)}u()}},this.printParams=()=>{let l=`let uiParams = {
`;return l+=`aperture: ${this.params.aperture},
`,l+=`focalLength: ${this.params.focalLength},
`,l+=`exposure: ${this.params.exposure},
`,l+=`focusHelp: ${this.params.focusHelp},
`,l+=`fov: ${this.params.fov},
`,l+=`extra: ${this.params.extra},
`,l+=`extra2: ${this.params.extra2},
`,l+=`extra3: ${this.params.extra3},
`,l+=`extra4: ${this.params.extra4},
`,l+="}",l+=`

`,l+="export {uiParams};",l};const e=this.addFolder("Camera"),n=this.addFolder("Parameters"),r=this.addFolder("Render");let a=this.params;e.add(this.params,"aperture",0,2,.001).name("Aperture").onChange(function(l){t.tracer.updateUniforms({aperture:l}),t.reset()}),e.add(this.params,"focalLength",0,40,.01).name("Focal Length").onChange(function(l){t.tracer.updateUniforms({focalLength:l}),t.reset()}),e.add(this.params,"focusHelp").name("Focus Help").onChange(function(l){t.tracer.updateUniforms({focusHelp:l}),t.reset()}),e.add(this.params,"fov",15,140,1).name("FOV").onChange(function(l){t.tracer.updateUniforms({fov:l}),t.reset()}),e.add(this.params,"exposure",0,2,.01).name("Exposure").onChange(function(l){t.tracer.updateUniforms({exposure:l}),t.reset()}),n.add(this.params,"extra",0,1,.001).onChange(function(l){t.tracer.updateUniforms({extra:l}),t.reset()}),n.add(this.params,"extra2",0,1,.001).onChange(function(l){t.tracer.updateUniforms({extra2:l}),t.reset()}),n.add(this.params,"extra3",0,1,.001).onChange(function(l){t.tracer.updateUniforms({extra3:l}),t.reset()}),n.add(this.params,"extra4",0,1,.001).onChange(function(l){t.tracer.updateUniforms({extra4:l}),t.reset()}),r.add(this.params,"resize").name("Size to Screen"),r.add(this.params,"preview").name("Preview Quality (Pixelated)").onChange(function(l){let c=1;l&&(c=1/4);let u={x:Math.floor(c*window.innerWidth),y:Math.floor(c*window.innerHeight)};t.accumulate.setSize(u),t.tracer.setSize(u)}),r.add(this.params,"autoSaveSPP").name("Auto Save At").onChange(function(l){t.autoSaveSPP=l}),r.add(this.params,"autoSave").name("Auto Save").onChange(function(l){t.autoSave=l});const o=r.addFolder("HD");o.close(),o.add(this.params,"panelWidth").name("Panel Width (px)").onFinishChange(function(l){t.resize({x:l,y:a.panelHeight})}),o.add(this.params,"panelHeight").name("Panel Height (px)").onFinishChange(function(l){t.resize({x:a.panelWidth,y:l})}),o.add(this.params,"numPanels",{1:1,4:4,9:9,16:16,25:25}).onFinishChange(function(l){t.tracer.updateUniforms({numPanels:l}),t.reset()}),o.add(this.params,"autoSavePanelsSPP").name("Auto Save At").onChange(function(l){t.autoSavePanelsSPP=l}),o.add(this.params,"autoSavePanels").onChange(function(l){t.autoSavePanels=l,t.tracer.updateUniforms({renderPanel:l}),t.tracer.updateUniforms({panelToRender:0}),t.reset()});const s=o.addFolder("Individual Panel");s.close(),s.add(this.params,"panelToRender").name("Current Panel").onFinishChange(function(l){t.tracer.updateUniforms({panelToRender:l}),t.reset()}),s.add(this.params,"renderPanel").name("Render This Panel").onChange(function(l){t.tracer.updateUniforms({renderPanel:l}),t.reset()}),this.add(this.params,"printSettings").name("Download Settings"),this.add(this.params,"saveit").name("Save Image")}}var Wf=`uniform float frameNumber;
uniform vec3 iResolution;
uniform sampler2D newTex;
uniform sampler2D accTex;

vec4 newFrame(ivec2 pixelCoord){
    return texelFetch(newTex, pixelCoord,0);
    
}

vec4 accFrame(ivec2 pixelCoord){
    return texelFetch(accTex, pixelCoord, 0);
    
}

void mainImage(out vec4 fragColor, in ivec2 pixelCoord )
{
    
    vec4 new = newFrame(pixelCoord);
    vec4 prev = accFrame(pixelCoord);

    
    new = isnan(length(new)) ? vec4(0,0,0,1) : new;

    
    float blend = (frameNumber < 2. || prev.a == 0.0f) ? 1.0f :  1. / (1. + 1./prev.a);
    vec3 color = mix(prev.rgb,new.rgb,blend);

    
    fragColor = vec4(color, blend);
}

void main() {
    mainImage(gl_FragColor, ivec2(gl_FragCoord.xy));
}`;let Xf={shader:Wf,uniforms:{frameNumber:{value:0},iResolution:{value:new L(window.innerWidth,window.innerHeight,0)},accTex:{value:null},newTex:{value:null}}};var qf=`vec3 LessThan(vec3 f, float value)
{
    return vec3(
    (f.x < value) ? 1.0f : 0.0f,
    (f.y < value) ? 1.0f : 0.0f,
    (f.z < value) ? 1.0f : 0.0f);
}

vec3 gammaCorrect(vec3 color){
    return pow(color, vec3(0.4545));
}

vec3 LinearToSRGB(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);

    return mix(
    pow(rgb, vec3(1.0f / 2.4f)) * 1.055f - 0.055f,
    rgb * 12.92f,
    LessThan(rgb, 0.0031308f)
    );
}

vec3 SRGBToLinear(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);

    return mix(
    pow(((rgb + 0.055f) / 1.055f), vec3(2.4f)),
    rgb / 12.92f,
    LessThan(rgb, 0.04045f)
    );
}

vec3 ACESFilm(vec3 x)
{
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return clamp((x*(a*x + b)) / (x*(c*x + d) + e), 0.0f, 1.0f);
}

vec3 Uncharted2(in vec3 color) {
    color *= 2.0;

    float A = 0.15, B = 0.50, C = 0.10;
    float D = 0.20, E = 0.02, F = 0.30;
    color = (((A * color + C * B) * color + D * E) / ((A * color + B) * color + D * F)) - E / F;

    
    
    color *= 1.9335;

    return color;
}

uniform vec3 iResolution;
uniform float iFrame;
uniform sampler2D accTex;

void mainImage( out vec4 fragColor, in ivec2 pixelCoord )
{

    
    vec3 color = texelFetch(accTex, pixelCoord, 0).rgb;

    
    

    
    color = ACESFilm(color);
   

    
    color = LinearToSRGB(color);
    

    fragColor = vec4(color, 1.0f);
}

void main() {

    mainImage(gl_FragColor, ivec2(gl_FragCoord.xy));
}`;let Yf={shader:qf,uniforms:{iResolution:{value:new L(window.innerWidth,window.innerHeight,0)},accTex:{value:null}}};var $f=`uniform vec3 iResolution;
uniform sampler2D sky;
uniform sampler2D skySM;
uniform mat3 facing;
uniform vec3 location;
uniform float frameNumber;
uniform float exposure;

uniform float aperture;
uniform float focalLength;
uniform float fov;
uniform bool focusHelp;
uniform float extra;
uniform float extra2;
uniform float extra3;
uniform float extra4;

uniform bool renderPanel;
uniform float numPanels;
uniform float panelToRender;

float PI=3.1415926;
float EPSILON=0.001;
float AT_THRESH=0.002;
int maxMarchSteps=2000;
float maxDist=100.;
int maxBounces=50;

bool trashBool;
float trashFloat;
vec3 debug;
float L1_Norm(vec3 p){
    return abs(p.x)+abs(p.y)+abs(p.z);
}

float L2_Norm(vec3 p){
    return length(p);
}

float LInf_Norm(vec3 p){
    p=abs(p);
    return max(p.x,max(p.y,p.z));
}

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float smax( float a, float b, float k )
{
    return -smin(-a,-b,k);
}

float smin(float a, float b){
    return smin(a,b,0.1);
}

float smax(float a, float b){
    return smax(a,b,0.1);
}

float sq(float x){return x*x;}

mat2 rot2(in float a){ float c = cos(a), s = sin(a); return mat2(c, -s, s, c); }
#define T vec2

T tfloat(float x) {
    return T(x,0);
}

T tmul(T z, T w) {
    return T(z.x*w.x,z.x*w.y+z.y*w.x); 
}

T tmul(T z, T w, T v) {
    return tmul(z,tmul(w,v));
}

T tmul(T z, T w, T u, T v) {
    return tmul(tmul(z,w),tmul(u,v));
}

T tsqr(T z) {
    
    return T(z.x*z.x,2.0*z.x*z.y);
}

T tcube(T z){
    return tmul(z,z,z);
}

T tfourth(T z){
    return tmul(tsqr(z),tsqr(z));
}

T tinv(T z){
    return T(1./z.x, -z.y/(z.x*z.x));
}

T tdiv(T x, T y){
    return tmul(x,tinv(y));
}

T tcheb(T x, int n) {
    for (int i = 0; i < n; i++) {
        x = 2.0*tsqr(x) - tfloat(1.0);
    }
    return x;
}

T tabs( T v){
    if( v.x < 0. ) {
        v.x = -v.x;
        v.y= -v.y;
    }
    return v;
}

T tpow(in T v, in float p){
    return pow( v.x , p - 1. ) *T( v.x , p * v.y );
}

T tmin(in T z, in T w){
    if( z.x < w.x ) return z;
    else return w;
}

T tmax(in T z, in T w){
    if( z.x > w.x ) return z;
    else return w;
}

T texp( T z){
    return exp(z.x)*T(1,z.y);
}

T tlog( T v){
    return T( log(v.x) , v.y / v.x );
}

T tsqrt( T v){
    float r = sqrt(v.x);
    return T( r , 0.5 * v.y / r );
}

T tcos(in T v){
    return T( cos( v.x ) , - v.y * sin( v.x ) );
}

T tsin(in T v){
    return T( sin( v.x ) ,  v.y * cos( v.x ) );
}

T ttan(in T v){
    return T( tan( v.x ) ,  v.y /( cos( v.x )*cos( v.x )) );
}

T tasin(in T v){
    return T( asin(v.x) , v.y / sqrt( 1. - v.x * v.x ) );
}

T tacos(in T v){
    return T( acos(v.x) , - v.y / sqrt( 1. - v.x * v.x ) );
}

T tatan(in T v){
    return T( atan(v.x) , v.y / ( 1. + v.x * v.x ) );
}

float DE(float val, float gradLength){
    float k = 1.-1./(abs(val)+1.);
    float param = 5.0; 
    float adjustedSpeed = gradLength+param*k+.001;

    
    float dist = val/adjustedSpeed;
    return 0.4*dist;
}

void invStereo( in T x, in T y, in T z, out T X, out T Y, out T Z, out T W){
    
    

    T denom = T(1,0) + tsqr(x) + tsqr(y) + tsqr(z); 
    T wNum = denom - T(2,0); 

    X = 2.* tdiv(x,denom);
    Y = 2.* tdiv(y,denom);
    Z = 2.* tdiv(z,denom);
    W = tdiv(wNum, denom);

}

void invStereo( in T x, in T y, out T X, out T Y, out T Z){
    
    

    T denom = tsqr(x) + tsqr(y)+ T(1,0); 
    T zNum = tsqr(x) + tsqr(y) - T(1,0); 

    X = tdiv(2.*x,denom);
    Y = tdiv(2.*y,denom);
    Z = tdiv(zNum, denom);

}

T gyroid(T x, T y, T z){
    T term1 = tmul(tsin(x),tcos(y));
    T term2 = tmul(tsin(y), tcos(z));
    T term3 = tmul(tsin(z),tcos(x));
    return 1.*(term1 + term2 + term3);
}

T barthSextic(T x, T y, T z){

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    float phi1=(1.+sqrt(5.))/2., phi2=phi1*phi1;

    T term1 = 4.*tmul(phi2*x2-y2, phi2*y2-z2, phi2*z2-x2);
    T term2 = (1.+2.*phi1) * tmul(x2+y2+z2-T(1,0),x2+y2+z2-T(1,0));

    return -(term1-term2);
}

T barthSextic(T x, T y, T z, T w){

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T w2 = tsqr(w);
    float phi1=(1.+sqrt(5.))/2., phi2=phi1*phi1;

    T term1 = 4.*tmul(phi2*x2-y2, phi2*y2-z2, phi2*z2-x2);
    T term2 = (1.+2.*phi1) * tmul(tsqr(x2+y2+z2-w2),w2);

    return -(term1-term2);
}

T barthDecic(T x, T y, T z, T w){

    

    T x2 = tsqr(x), x4 = tsqr(x2);
    T y2 = tsqr(y), y4 = tsqr(y2);
    T z2 = tsqr(z), z4 = tsqr(z2);
    T w2 = tsqr(w), w4 = tsqr(w2);
    float phi1=(1.+sqrt(5.))/2., phi2=phi1*phi1,  phi4 = phi2*phi2;

    T term1 = (x2 - phi4 * y2);
    T term2 = (y2 - phi4 * z2);
    T term3 = (z2 - phi4 * x2);
    T term4 = ( x4 + y4 + z4 - 2.* tmul(x2,y2) - 2.* tmul(x2, z2) - 2.* tmul(y2, z2) );

    T term5 = (3.+5.*phi1)*w2;
    T term6 = (x2 + y2 + z2 - w2);
    T term7 = (x2 + y2 + z2 - (2.-phi1)*(2.-phi1)* w2);

    return 8.*tmul(term1,term2,term3,term4) + tmul(term5,tsqr(term6),tsqr(term7));

    
    
    
}

T barthDecic(T x, T y, T z){
    return barthDecic(x,y,z,T(1,0));
}

T chmutov(T x, T y, T z) {
    int n = 2;
    return tcheb(x,n)+tcheb(y,n)+tcheb(z,n)+tfloat(1.0);
}

T kummer(T x, T y, T z, T w){

    
    float muSqr=1.5;
    
    float Lambda = (3.* muSqr - 1.)/(3.-muSqr);

    T p = z - w + x * sqrt(2.);
    T q = z - w - x * sqrt(2.);
    T r = z + w + y * sqrt(2.);
    T s = z + w - y * sqrt(2.);

    
    float coef = 1.;
    T fmu = tsqr(x) + tsqr(y) + tsqr(z) - coef * muSqr * tsqr(w);
    T prod = tmul(p,q,r,s);

    return tsqr(fmu) - Lambda * prod;
}

T kummer(T x, T y, T z){
    return kummer(x,y,z,T(1,0));
}

T togliatti(T xorig, T yorig, T zorig, T w){

    
    T x = xorig, y = -zorig, z = yorig;
    
    

    
    T x2 = tsqr(x), y2 = tsqr(y), z2 = tsqr(z), w2 = tsqr(w);

    T P1 = (x2 - 4.* tmul(x,w) - 10.*y2 - 4.*w2);
    T P2 = (16.*w2 - 20.*y2);

    T P = tmul(x2, P1) + tmul(tmul(x,w)+w2, P2) + 5.* tmul(y2, y2);
    T Q = 4.*(x2+y2-z2)+(1.+3.*sqrt(5.))*w2;
    T Q2 = tsqr(Q);
    T Qfin = tmul(2.* z - sqrt(5.-sqrt(5.)) * w,  Q2);
    T res =  64.*tmul(x-w, P) - 5.*sqrt(5.-sqrt(5.))*Qfin;
    return -res;

}

T togliatti(T xorig, T yorig, T zorig){
    return togliatti( xorig,  yorig,  zorig, T(1,0));
}

    
    T Labs7(T x, T y, T z, T w){

        float a = -0.140106854987125;
        
        float a1= -0.0785282014969835;
        float a2= -4.1583605922880200;
        float a3= -4.1471434889655100;
        float a4= -1.1881659380714800;
        float a5= 51.9426145948147000;

        
        T x2 = tsqr(x), y2 = tsqr(y), z2 = tsqr(z), w2 = tsqr(w);
        T x4 = tsqr(x2), y4 = tsqr(y2), z4 = tsqr(z2);
        T z6 = tmul(z2, z4);
        T r2 = x2+y2;

        T U = tmul(z+w,r2)+tmul(a1*z+a2*w,z2)+tmul(a3*z+a4*w,w2);
        U = tmul(z+a5*w,U,U);

        T P = tmul(x2-21.*y2,x4)+tmul(35.*x2-7.*y2,y4);
        P = tmul(x, P);
        P += tmul(z,7.*tmul(tmul(r2-8.*z2,r2) + 16.*z4, r2)-64.*z6);

        return U-P;
    }

T Labs7(T x, T y, T z){
    return Labs7(x,y,z,T(1,0));
}

T endrassOctic( T x, T y, T z, T w){

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T w2 = tsqr(w);
    T r2 = x2+y2, r4 = tsqr(r2);
    float s = sqrt(2.);

    T term1 = tmul((x2-w2),(y2-w2));
    T term2 = tsqr(x+y)-2.*w2;
    T term3 = tsqr(x-y)-2.*w2;
    T U = 64.*tmul(term1,term2,term3);

    T term4 = -4.*(1.+s)*r4;
    T term5 = (8.*(2.+s)*z2+2.*(2.+7.*s)*w2);
    T V = term4 + tmul(term5,r2);

    T term6 = (-16.*z2 + 8.*(1.-2.*s)*w2);
    T term7 = (1.+12.*s)*tsqr(w2);
    V = V + tmul(z2,term6) - term7;

    return tsqr(V)-U;

    
    
    
    
    
}

T endrassOctic(T x, T y, T z){
    return endrassOctic(x,y,z,T(1,0));
}

T endrassStereo(T x, T y, T z){
    T X, Y, Z, W;
    invStereo(x,y,z,X,Y,Z,W);
    return endrassOctic(X,Y,Z,W);
}

T sarti12(T x, T y, T z, T w){
    T x2 = tmul(x,x), y2 = tmul(y,y), z2 = tmul(z,z), w2 = tmul(w,w);
    T x4 = tmul(x2,x2), y4 = tmul(y2,y2), z4 = tmul(z2,z2), w4 = tmul(w2,w2);
    T l1 = x4+y4+z4+w4;
    T l2 = tmul(x2,y2)+tmul(z2,w2);
    T l3 = tmul(x2,z2)+tmul(y2,w2);
    T l4 = tmul(y2,z2)+tmul(x2,w2);
    T l5 = tmul(x,y,z,w);
    T s10 = tmul(l1,tmul(l2,l3)+tmul(l2,l4)+tmul(l3,l4));
    T s11 = tmul(tmul(l1,l1),l2+l3+l4);
    T s12=tmul(l1,tmul(l2,l2)+tmul(l3,l3)+tmul(l4,l4));
    T s51=tmul(tmul(l5,l5),l2+l3+l4);
    T s234=tmul(l2,l2,l2)+tmul(l3,l3,l3)+tmul(l4,l4,l4);
    T s23p=tmul(l2,l2+l3,l3), s23m=tmul(l2,l2-l3,l3);
    T s34p=tmul(l3,l3+l4,l4), s34m=tmul(l3,l3-l4,l4);
    T s42p=tmul(l4,l4+l2,l2), s42m=tmul(l4,l4-l2,l2);
    T Q12=x2+y2+z2+w2; Q12=tmul(Q12,Q12,Q12); Q12=tmul(Q12,Q12);
    T S12=33.0*sqrt(5.0)*(s23m+s34m+s42m)+19.0*(s23p+s34p+s42p)+10.0*s234-14.0*s10+2.0*s11-6.0*s12-352.0*s51+336.0*tmul(l5,l5,l1)+48.0*tmul(l2,l3,l4);
    return 22.0*Q12-243.0*S12;
}

T sarti12(T x, T y, T z){
    return sarti12(x,y,z,T(1,0));
}

T sartiStereo(T x, T y, T z){
    T X, Y, Z, W;
    invStereo(x,y,z,X,Y,Z,W);
    return sarti12(X,Y,Z,W);
}

T togliattiStereo(T x, T y, T z){
    T X, Y, Z, W;
    invStereo(x,y,z,X,Y,Z,W);
    return togliatti(X,Y,Z,W);
}

T kummerStereo(T x, T y, T z){
    T X, Y, Z, W;
    invStereo(x,y,z,X,Y,Z,W);
    return kummer(X,Y,Z,W);
}

T sexticStereo(T x, T y, T z){
    T X, Y, Z, W;
    invStereo(x,y,z,X,Y,Z,W);
    return barthSextic(X,Y,Z,W);
}

T decicStereo(T x, T y, T z){
    T X, Y, Z, W;
    invStereo(x,y,z,X,Y,Z,W);
    return barthDecic(X,Y,Z,W);
}

T sauermann(T x, T y, T z){
    
    
    

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);

    T a = T(0.45,0);
    T b = T(0.83,0);
    T c = T(1,0);
    T term1 = tmul(x2 + y2 + tsqr(z+a)-b, x2 + y2 + tsqr(z-a)-b);
    T term2 = tmul(x2 + y2 + tsqr(z+a)-c, x2 + y2 + tsqr(z-a)-c);
    T term3 = tmul(x2 + y2 + z2,x2 + y2 + tsqr(z2));

    T term4 = tmul(tsqr(x+y),tsqr(x-y));
    T term5 = tsqr(tmul(x,y));

    return tmul(term1, term2, term3) + tmul(term4, term5);

}

T sauermann2(T x, T y, T z){
    
    
    
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);

    T x4 = tsqr(x2);
    T y4 = tsqr(y2);
    T z4 = tsqr(z2);

    T term1 = z+T(1,0);
    T term2 = tsqr(z4-5.*tmul(z2,z)+6.*z2+z-T(2,0));

    T term3 = tmul(x2-T(1,0),y2-T(1,0));
    T term4 = x4-2.*tmul(x2,y2+T(2,0))+y4-4.*y2+T(4,0);

    return  tmul(term1,term2)-tmul(term3,term4);

}

T sauermann3(T x, T y, T z){
    
    
    
    z = -z;

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T x3 = tmul(x, x2);
    T y3 = tmul(y, y2);

    T term1 = x3+tmul(3.*x2, T(-1, 0)+y);
    T term2 = -3.*y2-3.*tmul(x, y2);
    T term3 = -y3+tmul(T(1, 0)+z, tsqr(T(1, 0)+2.*z-4.*z2));

    return -(term1 + term2 + term3);
}

T visavisVar(T x, T y, T z){
    
    

    T x2 = tsqr(x);
    T x3 = tmul(x, x2);
    T y2 = tsqr(y);
    T y4 = tsqr(y2);
    T z3 = tmul(z,z,z);
    T z4 = tmul(z,z3);

    return x2 - x3 + y2 + y4 + z3 - z4;
}

T kolibriVar(T x, T y, T z){
    
    
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T y3 = tmul(y2,y);

    return x2 - tmul(y2,z2) - y3;
}

T whitneyUmbrella(T x, T y, T z){
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);

    return x2 - tmul(z2,y);
}

T irisVar(T x, T y, T z){
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T z4 = tsqr(z2);

    return tmul(x2,y) - tmul(y2,z) + z4;
}

T calyxVar(T x, T y, T z){
    
    
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z3 = tmul(z,z,z);
    T z4 = tmul(z,z3);
    return x2 + tmul(y2,z3)-z4;
}

T daisyVar(T x, T y, T z){
   
    
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T y3 = tmul(y,y2);

    T term1 = x2-y3;
    T term2 = z2-y2;

    return tsqr(term1)-tmul(term2,term2,term2);
}

T dingdongVar(T x, T y, T z){
    
    
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T z3 = tmul(z2,z);

    return x2 + y2 + z3 - z2;
}

T thistleVar(T x, T y, T z){
    
    
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);

    T term1 = x2+y2;
    T term2 = x2+z2;
    T term3 = y2+z2;

    float c = 1500.;
    return x2 + y2 + z2 + c*tmul(term1,term2,term3)-T(1,0);
}

T eistuteVar(T x, T y, T z){
    
    
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);

    T term1 = x2+y2;
    T term2 = tmul(x2,y2);
    T term3 = z2+T(1,0);

    return (tmul(term1,term1,term1) - tmul(term2, term3));
}

T herzVar(T x, T y, T z){
    
    

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T z3 = tmul(z2,z);
    T z4 = tmul(z3,z);

    return y2 + z3 - z4 - tmul(x2,z2);
}

T kleinBottleVariety(T x, T y, T z){
    
    
   
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T r2 =  x2 + y2 + z2;
    T term1 = r2 + 2.*y - T(1,0);
    T term2 = r2 - 2.*y - T(1,0);

    return tmul(term1, tsqr(term2) - 8.*z2) + 16.*tmul(x,z,term2);
}

    
    

T crossCapVar(T x, T y, T z){
    
    

    
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    float a2 =0.5;
    float b2 =1.;

    T term1 =  x2/a2+y2/b2;
    T term2 = x2 + y2 + z2;
    T term3 = 2.*tmul(z,x2+y2);

    return tmul(term1, term2) - term3;
}

T romanSurfaceVar(T x, T y, T z){
    
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    float r2=1.;

    return tmul(x2,y2)+ tmul(y2,z2) + tmul(z2,x2) - r2*tmul(x,y,z);

}

T cubicTrivial(T x, T y, T z){
    
    

    float offset = 0.1;

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);

    return tmul(x2,y) + tmul(y2,z) + tmul(z2,x) - T(offset,0);

}

T cubicGenus(T x, T y, T z){
    
    T x3 = tmul(x,x,x);
    T y3 = tmul(y,y,y);
    T z3 = tmul(z,z,z);

    return x3 + y3 + z3 - (x+y+z);
}

    T clebschCubic(T x, T y, T z ){

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T x3 = tmul(x, x2);
    T y3 = tmul(y, y2);
    T z3 = tmul(z, z2);

    T term1 = 81.*(x3+y3+z3);
    T term2 = -189.*(tmul(x2, y)+tmul(x2, z)+tmul(y2, x)+tmul(y2, z)+tmul(z2, x)+tmul(z2, y));
    T term3 = 54.*tmul(x, y, z)+126.*(tmul(x, y)+tmul(x, z)+tmul(y, z));
    T term4 = -9.*(x+y+z);

    return term1 + term2 + term3 + term4 + T(1, 0);

}

    T cayleyNodalCubic(T x, T y, T z, T w){
    
    

    
    float offset =0.;

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T w2 = tsqr(w);

    return tmul(x2 + y2 + z2,w)+2.*tmul(x,y,z)-tmul(w,w,w)-T(offset,0);
}

    T cayleyNodalCubic(T x, T y, T z){
    return cayleyNodalCubic(x,y,z,T(1,0));
}

T riemannTwoBranch(T x, T y, T z){
    

    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T z4 = tsqr(z2);

    return tmul(z2,x2) + tmul(z2+T(1,0), y2) - 5.*(z4+z2);
}

T enneper(T x, T y, T z){

        
        
        float a = 1.;
        float a2 = a*a;
        float a3 = a*a*a;
        T x2 = tsqr(x);
        T y2 = tsqr(y);
        T z2 = tsqr(z);
        T z3 = tmul(z2,z);

    T term1 = a/2.*(y2-x2) + 2./9.* z3 + 2./3.*a2*z;
    T term2 = a/4.*(y2-x2) - 1./4.*tmul(z,x2+y2+8./9.*z2) + 2./9.*a2*z;

    return -tmul(term1,term1,term1) + 6.*a3*tmul(z,term2,term2);

}

    
    
    

    T mobiusStripVariety(T x, T y, T z){

    

    float a = 0.02;
    float b = 0.6;
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T t2 = x2+y2;

    T term1 = (a-b)*(tmul(x,t2-z2+T(1,0))-2.*tmul(y,z));
    T term2 = (2.*a + 2.*b + a*b)*t2;
    T term3 = (a+b)*(t2+z2+T(1,0));
    T term4 = 2.*(a-b)*(tmul(y,z)-x);

    T side1 = term1-term2;
    T side2 = (term3+term4);

    return -tsqr(side1)+tmul(t2,tsqr(side2));

}

    T mobiusStrip3TwistVariety(T x, T y, T z){

    

    float a = 0.01;
    float b = 0.33;
    T x2 = tsqr(x);
    T y2 = tsqr(y);
    T z2 = tsqr(z);
    T t2 = x2+y2;
    T t4 = tsqr(t2);

    T comp1 = 3.*tmul(x2,y)-tmul(y2,y);
    T comp2 = tmul(x,x2)-3.*tmul(x,y2);

    T term1 = -2.*(a+b)*t4+(a-b)*(tmul(comp1, t2-z2+T(1,0))-2.*tmul(comp2,z));
    T term2 = (a+b)*tmul(t2, (t2+z2+T(1,0))) - 2.*(a-b)*(comp1 - tmul(z,comp2)) - 2.*a*b*t2;

    return - tsqr(term1) + tmul(t2,tsqr(term2));

}

T ellipticFibration(T x, T y, T t){
    
    
    

    

    
    float lengthScale = 3.5;
    T r = tsqrt(tsqr(x)+tsqr(y));
    T scalingFactor = tsqr(texp(r/lengthScale))+tsqr(texp(-r/lengthScale));
    scalingFactor -= T(2,0);
    x = tmul(x,scalingFactor);
    y = tmul(y,scalingFactor);

    t = tmul(t,t,t);
    t = t/10.;
    
    

    T x2 = tsqr(x);
    T x3 = tmul(x,x2);
    T y2 = tsqr(y);

    return tmul(t, x2) - x3 - tmul(t,y) + tmul(T(1,0)-t,x,y) + y2;
}

T elliptic(T x, T y, T t){
    
    

    
    
   

    
    T newT = ttan(t);

    
    
    
    T X, Y, Z;
    invStereo(x,y,X,Y,Z);

    T X2 = tsqr(X);
    T Y2 = tsqr(Y);
    T Z2 = tsqr(Z);
    T X3 = tmul(X,X2);

    
    
    
    

    
    return -(tmul(newT,X2,Z) - X3 - tmul(newT, Y, Z2) + tmul(T(1,0)-newT,tmul(X,Y,Z)) + tmul(Y2,Z));
}
uint seed;

uint randomSeed(vec2 fCoord,float frame){

    uint seed = uint(uint(fCoord.x) * uint(1973) + uint(fCoord.y) * uint(925277) + uint(frame) * uint(26699)) | uint(1);
    return seed;

}

uint wang_hash()
{
    seed = uint(seed ^ uint(61)) ^ uint(seed >> uint(16));
    seed *= uint(9);
    seed = seed ^ (seed >> 4);
    seed *= uint(0x27d4eb2d);
    seed = seed ^ (seed >> 15);
    return seed;
}

float randomFloat(){
    return float(wang_hash()) / 4294967296.0;
}

float randomFloat(float a,float b){
    return a+(b-a)*randomFloat();
}

vec3 randomUnitVec3()
{
    float z = randomFloat() * 2.0f - 1.0f;
    float a = randomFloat() * 6.28;
    float r = sqrt(1.0f - z * z);
    float x = r * cos(a);
    float y = r * sin(a);
    return vec3(x, y, z);
}

vec2 randomGaussian2D(){
    float u=randomFloat();
    float v=randomFloat();

    float r=sqrt(abs(2.*log(u)));
    float x=r*cos(2.*PI*v);
    float y=r*sin(2.*PI*v);

    return vec2(x,y);

}

float randomGaussian(float mean, float stdev){

    
    float x=randomGaussian2D().x;

    
    return stdev*x+mean;
}

float randomExponential(float mean){
    float u = randomFloat();
    float x = - mean * log(1.-u);
    return x;
}
vec3 LessThan(vec3 f, float value)
{
    return vec3(
    (f.x < value) ? 1.0f : 0.0f,
    (f.y < value) ? 1.0f : 0.0f,
    (f.z < value) ? 1.0f : 0.0f);
}

vec3 LinearToSRGB(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);

    return mix(
    pow(rgb, vec3(1.0f / 2.4f)) * 1.055f - 0.055f,
    rgb * 12.92f,
    LessThan(rgb, 0.0031308f)
    );
}

vec3 SRGBToLinear(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);

    return mix(
    pow(((rgb + 0.055f) / 1.055f), vec3(2.4f)),
    rgb / 12.92f,
    LessThan(rgb, 0.04045f)
    );
}

vec2 toSphCoords(vec3 v){
    float theta=atan(-v.z,v.x);
    float phi=acos(v.y);
    return vec2(theta,phi);
}

vec3 toSphCoordsNoSeam(vec3 v){
    float theta=atan(-v.z,v.x);
    float theta2=atan(v.y,abs(v.x));
    float phi=acos(v.y);
    return vec3(theta,phi,theta2);
}

vec3 skyTex(vec3 v){

    vec3 angles=toSphCoordsNoSeam(v);

    
    float x=(angles.x+PI)/(2.*PI);
    float z=(angles.z+PI)/(2.*PI);

    float y=1.-angles.y/PI;

    vec2 uv=vec2(x,y);
    vec2 uv2=vec2(z,y);

    return SRGBToLinear(textureGrad(sky,uv,dFdx(uv2), dFdy(uv2)).rgb);

}
vec3 ORIGIN=vec3(0,0,0);

struct Vector{
    vec3 pos;
    vec3 dir; 
};

Vector trashVector;

Vector randomVector(vec3 pos){
    return Vector(pos,randomUnitVec3());
}

Vector add(Vector v, Vector w){
    
    return Vector(v.pos, v.dir+w.dir);
}

Vector negate(Vector v){
    return Vector(v.pos,-v.dir);
}

Vector sub(Vector v, Vector w){
    return add(v,negate(w));
}

Vector multiplyScalar(float a,Vector v) {
    return Vector(v.pos, a * v.dir);
}

Vector rotateByFacing(Vector v, mat3 facing){
    return Vector(v.pos,facing*v.dir);
}

Vector mix(Vector v, Vector w, float x){
    vec3 dir=mix(v.dir,w.dir,x);
    return Vector(v.pos,dir);
}

void nudge(inout Vector v, vec3 dir,float amt){
    v.pos+=dir*amt;
}

void nudge(inout Vector v, Vector offset,float amt){
    nudge(v,offset.dir,amt);
}

float vDot(Vector v, Vector w){
    return dot(v.dir,w.dir);
}

float vNorm(Vector v){
    return sqrt(vDot(v,v));
}

Vector vNormalize(Vector v){
    float length=vNorm(v);
    return multiplyScalar(1./length,v);
}

float cosAng(Vector v, Vector w){
    return vDot(vNormalize(v),vNormalize(w));
}

void flow(inout Vector tv, float t){
    
    tv.pos += t*tv.dir;
}

struct Isometry {
    mat4 mat;
};

Isometry trashIsometry;

const Isometry identity = Isometry(mat4(1));

Isometry composeIsometry(Isometry isom1, Isometry isom2) {
    return Isometry(isom1.mat * isom2.mat);
}

Isometry getInverse(Isometry isom) {
    return Isometry(inverse(isom.mat));
}

vec3 translate(Isometry isom, vec3 p) {
    vec4 coords=isom.mat * vec4(p,1.);
    return coords.xyz;
}

Vector translate(Isometry isom, Vector v) {
    
    vec3 newPos=translate(isom, v.pos);
    vec3 newDir=(isom.mat*vec4(v.dir,0.)).xyz;
    return Vector(newPos,newDir);
}

Isometry makeTranslation(vec3 p){
    
    mat4 mat=mat4(1.,0.,0.,0.,
    0.,1.,0.,0.,
    0.,0.,1.,0.,
    p.x,p.y,p.z,1.);
    return Isometry(mat);
}

Isometry makeRotation(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    mat4 mat= mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
    oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
    0.0,                                0.0,                                0.0,                                1.0);
    return Isometry(mat);
}

Isometry makeIsometry(vec3 pos, vec3 axis, float angle){

    Isometry trans=makeTranslation(pos);
    Isometry rot=makeRotation(axis, angle);

    
    return composeIsometry(trans,rot);

}
Vector vReflect(Vector v, Vector n){
    return add(multiplyScalar(-2.0 * vDot(v, n), n), v);
}

Vector vRefract(Vector incident, Vector normal, float n){

    float cosX=-vDot(normal, incident);
    float sinT2=n*n* (1.0 - cosX * cosX);

    if (sinT2>1.){
        
        return Vector(incident.pos,vec3(0.,0.,0.));
        
    }

    
    
    

    float cosT=sqrt(1.0 - sinT2);
    vec3 dir=n*incident.dir+(n * cosX - cosT) * normal.dir;
    return Vector(incident.pos, dir);

}

float FresnelReflectAmount(float n, Vector normal, Vector incident, float f0, float f90)
{
    

    
    float r0 = (n-1.)/(n+1.);
    r0 *= r0;
    float cosX = -vDot(normal, incident);
    if (n>1.)
    {
        float sinT2 = n*n*(1.0-cosX*cosX);
        
        if (sinT2 > 1.0){
            return f90;
        }
        cosX = sqrt(1.0-sinT2);
    }
    float x = 1.0-cosX;
    float ret = clamp(r0+(1.0-r0)*x*x*x*x*x,0.,1.);

    
    
    return  f0 + (f90-f0)*ret;
}
struct Camera{
    vec3 pos;
    mat3 facing;
    float fov;
    float aperture;
    float focalLength;
    bool renderPanel;
    float numPanels;
    float panelToRender;
};

Camera buildCamFromUniforms(){
    Camera cam;
    cam.pos=location;
    cam.facing=facing;
    cam.fov=fov;
    cam.aperture=aperture;
    cam.focalLength=focalLength;
    cam.renderPanel = renderPanel;
    cam.numPanels = numPanels;
    cam.panelToRender = panelToRender;
    return cam;
}

Vector initializeRay(vec2 fragCoord, float FOV){

    
    vec3 rayPosition = ORIGIN;

    
    vec2 jitter = vec2(randomFloat(), randomFloat()) - 0.5f;

    
    vec2 planeCoords=((fragCoord+jitter)/iResolution.xy) * 2.0f - 1.0f;

    
    float aspectRatio = iResolution.x / iResolution.y;
    planeCoords.y /= aspectRatio;

    
    float z=-1./ tan(radians(FOV * 0.5));

    
    vec3 rayTarget = vec3(planeCoords, z);

    
    
    vec3 rayDir = normalize(rayTarget);

    
    Vector tv=Vector(rayPosition,rayDir);

    return tv;

}

vec2 sampleAperture(Camera cam){

    float theta=2.*PI*randomFloat();
    float radius=cam.aperture*sqrt(randomFloat());

    vec2 offset=radius*vec2(cos(theta),sin(theta));
    return offset;
}

vec2 panelFragCoord(vec2 fragCoord, float nPanels, float panelToRender){

    
   if(panelToRender<nPanels){
       float resize = sqrt(nPanels);
       float panelFraction = panelToRender/resize;

       
       float panelRow = floor(panelFraction);
       float panelColumn = floor(fract(panelFraction)*resize);
       vec2 chosenPanel=vec2(panelRow, panelColumn);

       
       vec2 newFragCoord = fragCoord/resize;
       vec2 offset = chosenPanel * iResolution.xy/resize;
       newFragCoord += offset;
       return newFragCoord;
   }

    
    return fragCoord;
}

Vector cameraRay(vec2 fragCoord, Camera cam){

    
    vec3 startPos=vec3(-2,0,6);

    
    if(cam.renderPanel){
        fragCoord = panelFragCoord(fragCoord, cam.numPanels, cam.panelToRender);
    }

    
    Vector tv=initializeRay(fragCoord,cam.fov);

    
    vec3 focalPt=tv.pos+cam.focalLength*tv.dir;

    
    vec2 offset=sampleAperture(cam);
    vec3 pos=tv.pos;
    pos.xy+=offset;

    
    vec3 dir=normalize(focalPt-pos);

    
    tv=Vector(pos,dir);

    
    
    
    tv.pos=facing*tv.pos;

    
    tv.pos+=cam.pos+startPos;

    
    tv=rotateByFacing(tv,cam.facing);

    return tv;
}
struct Material{
    bool render;
    bool subSurface;
    vec3 surfaceEmit;
    vec3 diffuseColor;
    vec3 specularColor;
    vec3 diffuseColorBack;
    vec3 specularColorBack;
    vec3 absorbColor;
    vec3 emitColor;
    float roughness;
    float isotropicScatter;
    float meanFreePath;
    float IOR;
    float specularChance;
    float refractionChance;
};

void zeroMat(inout Material mat){
    
    mat.render=true;
    mat.subSurface=false;
    mat.surfaceEmit=vec3(0.);
    mat.diffuseColor=vec3(1.);
    mat.specularColor=vec3(1.);
    mat.diffuseColorBack=vec3(1.);
    mat.specularColorBack=vec3(1.);
    mat.absorbColor=vec3(0.);
    mat.isotropicScatter=1.;
    mat.roughness=0.;
    mat.IOR=1.;
    mat.meanFreePath=1.;
    mat.specularChance=0.;
    mat.refractionChance=0.;
}

void setMetal(inout Material mat, vec3 color, float specularity,float roughness){
    zeroMat(mat);
    mat.diffuseColor=color;
    mat.specularColor=vec3(2.)+0.8*color;
    mat.roughness=roughness;
    mat.specularChance=specularity;
    mat.refractionChance=0.;
}

Material makeMetal(vec3 color, float specularity, float roughness){

    Material mat;

    setMetal(mat,color,specularity,roughness);

    return mat;

}

void setDielectric(inout Material mat, vec3 color, float specularity, float roughness){
    zeroMat(mat);

    mat.diffuseColor=color;
    mat.specularColor=vec3(0.9);
    mat.roughness=roughness;
    mat.specularChance=specularity;
    mat.refractionChance=0.;

}

Material makeDielectric(vec3 color, float specularity, float roughness){

    Material mat;

    setDielectric(mat,color,specularity,roughness);

    return mat;

}

Material air(vec3 absorbColor){

    Material mat;
    zeroMat(mat);
    mat.render=false;
    mat.absorbColor=absorbColor;

    return mat;
}

void setGlass(inout Material mat, vec3 color, float IOR,float refractivity){

    zeroMat(mat);
    mat.render=true;

    mat.specularColor=vec3(1.);
    mat.diffuseColor=vec3(1.);
    mat.absorbColor=vec3(color);

    mat.IOR=IOR;

    mat.refractionChance=refractivity;
    float remainder=1.-refractivity;
    mat.specularChance=0.9*remainder;
    

}

void setGlass(inout Material mat, vec3 color, float IOR){

    setGlass(mat,color,IOR,0.95);

}

Material makeGlass(vec3 color, float IOR,float specularity){
    Material mat;

    setGlass(mat, color,IOR,specularity);
    return mat;
}

Material makeGlass(vec3 color, float IOR){
    return makeGlass(color,IOR,0.95);
}

Material makeLight(vec3 color,float intensity){
    Material mat;
    zeroMat(mat);

    mat.surfaceEmit=intensity*color;

    return mat;
}

void setLight(inout Material mat, vec3 color,float intensity){
    zeroMat(mat);

    mat.surfaceEmit=intensity*color;

}
struct localData{

    bool isPhysical;
    bool isSky;
    bool renderMaterial;

    float side;
    bool subSurface;
    float meanFreePath;
    float isotropicScatter;
    vec3 surfDiffuse;
    vec3 surfSpecular;
    vec3 surfEmit;
    float surfRoughness;
    float probDiffuse;
    float probSpecular;
    float probRefract;
    float IOR;
    vec3 refractAbsorb;
    vec3 reflectAbsorb;
    vec3 refractEmit;
    vec3 reflectEmit;

    Vector normal;
};

localData trashDat;

void initializeData(localData dat){
    dat.subSurface=false;
    dat.isSky=false;
    dat.isPhysical=true;
    dat.renderMaterial=true;
    dat.reflectAbsorb=vec3(0.);
    dat.refractAbsorb=vec3(0.);
    dat.surfDiffuse=vec3(1.);
    dat.surfSpecular=vec3(1.);
    dat.surfEmit=vec3(0.);
    dat.surfRoughness=0.;
    dat.isotropicScatter=0.;
    dat.meanFreePath=1.;
    dat.reflectEmit=vec3(0);
    dat.refractEmit=vec3(0);
    dat.IOR=1.;
    dat.probDiffuse=1.;
    dat.probRefract=0.;
    dat.probSpecular=0.;
}

struct Path{

    Vector tv;
    vec3 pixel;
    vec3 light;

    int type;
    float prob;
    vec3 absorb;
    vec3 emit;
    float distance; 
    float totalDistance;
    float numScatters;
    localData dat;

    bool keepGoing;
    bool subSurface;

    vec3 debug;

};

Path initializePath(Vector tv){
    Path path;

    path.tv=tv;
    path.pixel=vec3(0.);
    path.light=vec3(1.);
    path.numScatters=0.;
    path.distance=0.;
    path.totalDistance=0.;
    path.keepGoing=true;
    path.subSurface=false;

    path.type=1;
    path.prob=1.;

    initializeData(path.dat);

    path.debug=vec3(0.);
    path.absorb=vec3(0.);
    path.emit = vec3(0);
    return path;

}
void setObjectInAir(inout localData dat, bool inside, Vector normal, Material mat){

    
    dat.renderMaterial=mat.render;
    dat.isSky=false;
    dat.surfDiffuse=mat.diffuseColor;
    dat.surfSpecular=mat.specularColor;
    dat.surfEmit=mat.surfaceEmit;
    dat.surfRoughness=mat.roughness;
    dat.probDiffuse=1.-mat.specularChance-mat.refractionChance;
    dat.probSpecular=mat.specularChance;
    dat.probRefract=mat.refractionChance;

    if(inside){
        
        dat.normal=negate(normal);
        
        dat.IOR=mat.IOR/1.;
        dat.reflectEmit = mat.emitColor;
        dat.reflectAbsorb=mat.absorbColor;
        dat.refractAbsorb=vec3(0.);
        dat.refractEmit=vec3(0.);
        dat.subSurface=false;
        dat.meanFreePath=maxDist;
        dat.isotropicScatter=0.;
    }

    else{
        
        dat.normal=normal;
        
        dat.IOR=1./mat.IOR;
        dat.reflectAbsorb=vec3(0.);
        dat.refractAbsorb=mat.absorbColor;
        dat.reflectEmit=vec3(0.);
        dat.refractEmit=mat.emitColor;
        dat.subSurface=mat.subSurface;
        dat.meanFreePath=mat.meanFreePath;
        dat.isotropicScatter=mat.isotropicScatter;
    }

}

void setSurfaceInMat(inout localData dat, float side, Vector normal, Material surf,Material mat){

    
    dat.renderMaterial=surf.render;
    dat.isSky=false;
    dat.surfEmit=surf.surfaceEmit;
    dat.surfRoughness=surf.roughness;
    dat.probDiffuse=1.-surf.specularChance-surf.refractionChance;
    dat.probSpecular=surf.specularChance;
    dat.probRefract=surf.refractionChance;

    
    dat.reflectAbsorb=mat.absorbColor;
    dat.refractAbsorb=mat.absorbColor;
    dat.reflectEmit=mat.emitColor;
    dat.refractEmit=mat.emitColor;
    dat.IOR=1.;
    dat.subSurface=false;

    if(side<0.){
        
        dat.normal=negate(normal);
        dat.surfDiffuse=surf.diffuseColorBack;
        dat.surfSpecular=surf.specularColorBack;
    }

    else{
        
        dat.normal=normal;
        dat.surfDiffuse=surf.diffuseColor;
        dat.surfSpecular=surf.specularColor;
    }

}

void setMaterialInterface(inout localData dat, Material current, Material neighbor, Material dominant ){

    dat.renderMaterial=true;

    

    
    dat.probSpecular=dominant.specularChance;
    dat.probRefract=dominant.refractionChance;
    dat.probDiffuse=1.-dat.probRefract-dat.probSpecular;

    
    dat.surfDiffuse=dominant.diffuseColor;
    dat.surfSpecular=dominant.specularColor;
    dat.surfEmit=dominant.surfaceEmit;
    

    

    
    dat.IOR=current.IOR/neighbor.IOR;

    
    dat.subSurface=neighbor.subSurface;
    dat.surfRoughness=neighbor.roughness;
    dat.meanFreePath=neighbor.meanFreePath;
    dat.isotropicScatter=neighbor.isotropicScatter;

    dat.reflectAbsorb=current.absorbColor;
    dat.refractAbsorb=neighbor.absorbColor;

    dat.reflectEmit=current.emitColor;
    dat.refractEmit=neighbor.emitColor;

}
void updateProbabilities( inout Path path ){

    
    if(path.dat.probSpecular!=0.){
        
        Vector normal=path.dat.normal;

        float origSpec=path.dat.probSpecular;

        path.dat.probSpecular = FresnelReflectAmount(path.dat.IOR, path.tv, normal, origSpec, 1.0);

        
        float chanceMultiplier = (1.0 - path.dat.probSpecular) / (1.0 - origSpec);

        path.dat.probRefract  *= chanceMultiplier;
        path.dat.probDiffuse = 1.-path.dat.probRefract-path.dat.probSpecular;
    }

}

void scatter( inout Path path){

    if(path.dat.renderMaterial){

        updateProbabilities(path);

        
        float random=randomFloat();

        
        Vector normal=path.dat.normal;
        Vector randomDir=randomVector(path.tv.pos);
        Vector diffuseDir=vNormalize(add(normal, randomDir));
        Vector newDir;

        
        float rough2=path.dat.surfRoughness * path.dat.surfRoughness;

        if (random<path.dat.probSpecular){

            
            path.type=2;
            path.prob=path.dat.probSpecular;
            path.absorb=path.dat.reflectAbsorb;
            path.emit=path.dat.reflectEmit;
            path.subSurface=false;

            newDir=vReflect(path.tv, normal);
            newDir=vNormalize(mix(newDir, diffuseDir,rough2));

        }

        else if (random<path.dat.probRefract+path.dat.probSpecular){

            
            path.type=3;
            path.prob=path.dat.probRefract;
            path.absorb=path.dat.refractAbsorb;
            path.emit=path.dat.refractEmit;
            path.subSurface=false;

            newDir=vRefract(path.tv, normal, path.dat.IOR);
            newDir=vNormalize(mix(newDir, negate(diffuseDir),rough2));

        }

        else {

            
            path.prob=path.dat.probDiffuse;

            
            
            if(path.dat.subSurface){
                path.subSurface=true;
                path.type=3;
                path.absorb=path.dat.refractAbsorb;
                path.emit=path.dat.refractEmit;
                newDir=vRefract(path.tv, normal, path.dat.IOR);
            }

            else{
                
                path.type=1;
                path.absorb=path.dat.reflectAbsorb;
                path.emit=path.dat.reflectEmit;
                newDir=diffuseDir;
            }

        }

        
        path.prob=max(path.prob, 0.001);
        path.light /= path.prob;

        
        path.tv=newDir;

        
        
        
        flow(path.tv,10.*EPSILON);

    }

    else{
        

        
        path.type=3;
        path.prob=1.;
        path.absorb=path.dat.refractAbsorb;
        path.emit=path.dat.refractEmit;
        path.subSurface=false;

        
        flow(path.tv,10.*EPSILON);
    }

}
void updateFromVolume(inout Path path){

    vec3 beersLaw = path.absorb*path.distance;

    if(length(beersLaw)>0.0001){
        path.light *= exp( -beersLaw );
    }
}

void updateFromSubSurf(inout Path path){

    
    

    vec3 beersLaw = path.absorb*path.distance;
    vec3 emitAmt = path.emit*path.distance;

    if(length(beersLaw)>0.0001){
        emitAmt *= exp( -beersLaw);
        path.light *= exp( -beersLaw );
    }

    if(length(emitAmt)>0.0001){
        path.pixel += path.light*emitAmt;
    }
}

void updateFromSurface(inout Path path){

    
    if(path.dat.renderMaterial){

        
        if (length(path.dat.surfEmit)>0.001){
            path.pixel += path.light * path.dat.surfEmit;
        }

        
        if (path.type == 1){
            path.light *=  path.dat.surfDiffuse;
        }
        if (path.type == 2){
            path.light *=  path.dat.surfSpecular;
        }

    }

}

void updateFromSky(inout Path path){
    if(path.dat.isSky){
        vec3 skyColor = skyTex(path.tv.dir);
        
        path.pixel += path.light*skyColor;
        path.keepGoing = false;
    }
}

void focusCheck(inout Path path){
    if(focusHelp){

        float distToFocalPlane = abs(path.totalDistance-focalLength);

        if(distToFocalPlane<0.03){
            path.pixel+=vec3(0,1,1);
        }
        if(distToFocalPlane<0.12){
            path.pixel+=vec3(0,1,0);
        }
        else if(distToFocalPlane<0.25){
            path.pixel+=vec3(0.5,0.5,0.);
        }
        else if(distToFocalPlane<0.5){
            path.pixel+=vec3(1.,0.,0.);
        }
    }

}

void roulette(inout Path path){

    
    

    float p = LInf_Norm(path.light);
    if (randomFloat() > p){
        path.keepGoing = false;
    }
    
    if(p>0.001){
        path.light *= 1. / p;
    }
}

vec2 opRevolution( in vec3 p, float w )
{
    return vec2( length(p.xz) - w, p.y );
}

vec3 opRevolutionOutputNormal(in vec3 p, float w, vec2 n){

    
    vec3 rVec=normalize(vec3(p.x,0,p.z));
    vec3 hVec=vec3(0,1,0);

    return n.x*rVec+n.y*hVec;
}

float opMinDist(float distA, float distB, float k){
    float h = max(k-abs(distA-distB),0.0);
    float m = 0.25*h*h/k;
    return min(distA,distB)-m;
}

vec3 opMinVec(float distA, vec3 nvecA, float distB, vec3 nvecB, float k){
    float h = max(k-abs(distA-distB),0.0);
    float n=0.5*h/k;
    float f=(distA<distB)?n:1.-n;
    return normalize(mix(nvecA, nvecB, f));
}

float opMaxDist( float a, float b, float k )
{
    return -opMinDist(-a,-b,k);
}

vec3 opMaxVec(float distA, vec3 nvecA, float distB, vec3 nvecB, float k){
    return opMinVec(-distA, nvecA,-distB, nvecB,k);
}

float opOnionDist(float dist, float thickness){
    return abs(dist)-thickness;
}

vec3 opOnionVec(float dist,vec3 nVec){
    return sign(dist)*nVec;
}

vec3 opTwist( vec3 p )
{
    float k =50.0; 
    float c = cos(k*p.y);
    float s = sin(k*p.y);
    mat2  m = mat2(c,-s,s,c);
    vec2 rot=m*p.xz;
    vec3  q = vec3(rot.x,p.y,rot.y);
    return q;
}

float opExtrusion(in float sdf, in float pz, in float h){

    
    

    
    const float sf = .028;
    vec2 w = vec2( sdf, abs(pz) - h ) + sf;
    return min(max(w.x, w.y), 0.) + length(max(w, 0.)) - sf;

}

vec3 sdgBox( in vec2 p, in vec2 b )
{
    vec2 w = abs(p)-b;
    vec2 s = vec2(p.x<0.0?-1:1,p.y<0.0?-1:1);
    float g = max(w.x,w.y);
    vec2  q = max(w,0.0);
    float l = length(q);
    return vec3(   (g>0.0)?l  :g,
    s*((g>0.0)?q/l:((w.x>w.y)?vec2(1,0):vec2(0,1))));
}

float cylinderDist(vec3 pos, float radius, float height, float rounded){

    vec2 p=vec2( length(pos.xz) , pos.y);
    
    vec2 b=vec2(radius-rounded, height);

    vec2 w = abs(p)-b;
    float g = max(w.x,w.y);
    vec2  q = max(w,0.0);
    float l = length(q);

    float dist= (g>0.0) ?  l  :g;
    return dist-rounded;
}
struct Box{
    vec3 center;
    vec3 sides;
    float rounded;
    Material mat;
};

float distR3( vec3 p, Box box ){
    
    vec3 pos = p - box.center;

    vec3 q = abs(pos) - box.sides;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - box.rounded;
}

bvec2 relPosition( Vector tv, Box box){

    float d = distR3( tv.pos, box );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    bool inside = d<0.;
    return bvec2(atSurf, inside);
}

bool at( Vector tv,Box box){

    float d = distR3( tv.pos, box );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Box box ){
    float d = distR3( tv.pos, box );
    return (d<0.);
}

float sdf( Vector tv, Box box ){

    
    float d=distR3(tv.pos, box);
    return d;
}

Vector normalVec( Vector tv, Box box ){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, box);
    float vyyx=distR3( pos + e.yyx*ep, box);
    float vyxy=distR3( pos + e.yxy*ep, box);
    float vxxx=distR3( pos + e.xxx*ep, box);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}

void setData( inout Path path, Box box){

    
    if(at(path.tv, box)){
        
        Vector normal=normalVec(path.tv,box);
        bool side = inside(path.tv, box);
        
        setObjectInAir(path.dat, side, normal, box.mat);
    }

}
struct Plane{

    Vector orientation;
    Material mat;
};

float distR3( vec3 pos, Plane plane ){

    
    vec3 relPos = pos - plane.orientation.pos;

    
    return dot( relPos, plane.orientation.dir );

}

bool at( Vector tv, Plane plane){

    float d = distR3( tv.pos, plane );
    return  (abs(d) < AT_THRESH);

}

bool inside( Vector tv, Plane plane ){
    float d = distR3( tv.pos, plane );
    return (d < 0.);
}

float sdf( Vector tv, Plane plane ){

    
    if(dot(tv.dir,plane.orientation.dir)>0.){return maxDist;}

    
    return distR3(tv.pos, plane);
}

Vector normalVec( Vector tv,Plane plane ){
    
    return Vector(tv.pos, plane.orientation.dir);
}

float trace( Vector tv, Plane plane ){

    float denom=dot(tv.dir,plane.orientation.dir);
    if(denom>0.){return maxDist;}

    
    return - distR3( tv.pos, plane) / denom;
}

void setData( inout Path path, Plane plane ){

    
    if(at(path.tv, plane)){
        
        Vector normal=normalVec(path.tv, plane);
        bool side = inside(path.tv, plane);
        
        setObjectInAir(path.dat, side, normal, plane.mat);
    }

}
struct Sphere{
    vec3 center;
    float radius;
    Material mat;
};

float distR3( vec3 p, Sphere sphere ){
    
    vec3 pos = p - sphere.center;

    
    return length(pos) - sphere.radius;
}

bvec2 relPosition( Vector tv, Sphere sphere){

    float d = distR3( tv.pos, sphere );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    bool inside = d<0.;
    return bvec2(atSurf, inside);
}

bool at( Vector tv, Sphere sphere){

    float d = distR3( tv.pos, sphere );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Sphere sphere ){
    float d = distR3( tv.pos, sphere );
    return (d<0.);
}

float sdf( Vector tv, Sphere sphere ){

    
    float d=distR3(tv.pos, sphere);
    return d;

}

Vector normalVec( Vector tv, Sphere sphere ){
    
    vec3 dir = tv.pos-sphere.center;
    dir=normalize(dir);

    return Vector(tv.pos,dir);
}

vec2 intersectRay_Sphere( Vector tv, Sphere sphere ){
    
    vec3 p=tv.pos-sphere.center;
    vec3 v=tv.dir;

    float a=dot(v,v);
    float b=2.*dot(p,v);
    float c=(dot(p,p)-sphere.radius*sphere.radius)/a;

    float disc=b*b-4.*a*c;
    if(disc<0.){
        
        return 2.*vec2(maxDist,maxDist);
    }
    
    float D=sqrt(abs(disc));
    return vec2(-b-D, -b+D)/(2.*a);

}

float trace( Vector tv, Sphere sphere ){

    vec2 intPt=intersectRay_Sphere(tv, sphere);

    if(intPt.y < 0. || intPt.x > maxDist){
        
        return maxDist;
    }
    
    float dist=intPt.x < 0.  ?  intPt.y  :  intPt.x;
    return min(dist,maxDist);
}

void setData( inout Path path, Sphere sphere ){

    
    if(at(path.tv, sphere)){
        
        Vector normal=normalVec(path.tv,sphere);
        bool side = inside(path.tv, sphere);
        
        setObjectInAir(path.dat, side, normal, sphere.mat);
    }

}

float sdRoundBox( vec3 p, vec3 b, float r )
{
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}
struct Torus{
    vec3 center;
    float innerR;
    float outerR;
    Material mat;
};

float sdTorus( vec3 pos, float ra, float rb  ){
    
    vec3 p = vec3(pos.x,pos.z,-pos.y);

    float h = length(p.xz);
    float dist =  length(vec2(h-ra,p.y))-rb;

    return dist;
}

float distR3( vec3 pos, Torus torus ){
    
    pos = vec3(pos.x,pos.z,-pos.y);
    vec3 p = (pos - torus.center);

    float rb = torus.innerR;
    float ra = torus.outerR;

    float h = length(p.xz);
    float dist =  length(vec2(h-ra,p.y))-rb;

    return dist;
}

bool at( Vector tv, Torus torus){

    float d = distR3( tv.pos, torus );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Torus torus ){
    float d = distR3( tv.pos, torus );
    return (d<0.);
}

float sdf( Vector tv, Torus torus ){
    return distR3(tv.pos, torus);
}

Vector normalVec( Vector tv, Torus torus ){

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    vec3 pos = tv.pos;

    float vxyy=distR3( pos + e.xyy*ep, torus);
    float vyyx=distR3( pos + e.yyx*ep, torus);
    float vyxy=distR3( pos + e.yxy*ep, torus);
    float vxxx=distR3( pos + e.xxx*ep, torus);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}

void setData( inout Path path, Torus torus ){

    
    if(at(path.tv, torus)){
        
        Vector normal=normalVec(path.tv, torus);
        bool side = inside(path.tv, torus);
        
        setObjectInAir(path.dat, side, normal, torus.mat);
    }

}
struct Cone{
    vec3 center;
    float height;
    float base;

    float flare;
    Material mat;
};

float sdCappedCone( vec3 p, float h, float r1, float r2 )
{
    vec2 q = vec2( length(p.xz), p.y );
    vec2 k1 = vec2(r2,h);
    vec2 k2 = vec2(r2-r1,2.0*h);
    vec2 ca = vec2(q.x-min(q.x,(q.y<0.0)?r1:r2), abs(q.y)-h);
    vec2 cb = q - k1 + k2*clamp( dot(k1-q,k2)/dot(k2,k2), 0.0, 1.0 );
    float s = (cb.x<0.0 && ca.y<0.0) ? -1.0 : 1.0;
    return s*sqrt( min(dot(ca,ca),dot(cb,cb)) );
}

float distR3( vec3 p, Cone cone ){
    
    vec3 pos = p - cone.center;
    return sdCappedCone(pos,cone.height,cone.base,cone.flare*cone.base);
}

bool at( Vector tv, Cone cone){

    float d = distR3( tv.pos, cone );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Cone cone ){
    float d = distR3( tv.pos, cone );
    return (d<0.);
}

float sdf( Vector tv, Cone cone ){

    
    return distR3(tv.pos, cone);

}

Vector normalVec( Vector tv, Cone cone ){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, cone);
    float vyyx=distR3( pos + e.yyx*ep, cone);
    float vyxy=distR3( pos + e.yxy*ep, cone);
    float vxxx=distR3( pos + e.xxx*ep, cone);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}

void setData( inout Path path, Cone cone ){

    
    if(at(path.tv, cone)){
        
        Vector normal=normalVec(path.tv,cone);
        bool side = inside(path.tv, cone);
        
        setObjectInAir(path.dat, side, normal, cone.mat);
    }

}`,jf=`void buildScene(){
    buildEnvironment();
    buildObjects();
}

float sdf_Scene( Vector tv ){
    float dist=maxDist;

    dist=min(dist, sdf_Environment( tv ));
    dist=min(dist, sdf_Objects( tv ));

    return dist;

}

float trace_Scene( Vector tv ){
    float dist=maxDist;

    dist = min(dist, trace_Environment(tv));
    dist = min( dist, trace_Objects(tv) );

    return dist;
}

void setData_Scene(inout Path path){

    
    setData_Objects(path);
    setData_Environment(path);

}
float raymarch(Vector tv, float stopDist){

    float totalDist=0.;
    float distToScene=0.;
    float marchFactor=0.9;

    for (int i = 0; i < maxMarchSteps; i++){

        distToScene = abs(sdf_Scene( tv ));

        if (distToScene< EPSILON){
            return totalDist+distToScene;
        }

        
        distToScene *= marchFactor;
        totalDist += distToScene;

        if(totalDist>stopDist){
            
            return stopDist;
        }

        
        flow(tv, distToScene);
    }

    
    return stopDist;
}
float raytrace(Vector tv, float stopDist){

    float dist =  trace_Scene( tv ) ;

    
    if(dist<stopDist){
        
        return dist- EPSILON/2.;
    }

    
    return stopDist;
}
void stepForward(inout Path path){
    bool insideVar=false;
    float distance=maxDist;

    
    distance=raytrace( path.tv, distance );

    
    distance=raymarch( path.tv, distance );

    
    
    path.distance=distance;
    path.totalDistance+=distance;
    flow(path.tv,distance);

    
    path.dat.isSky=(path.distance>maxDist-0.1);
    if(!path.dat.isSky){
        setData_Scene(path);
    }

}
float bisect_Scatter(Vector tv, float dt){
    float dist=0.;
    
    float testDist=dt;
    Vector temp;

    for(int i=0;i<10;i++){

        
        testDist=testDist/2.;

        
        temp=tv;
        flow(temp, dist+testDist);
        
        if(inside_Object(temp)){
            dist+=testDist;
        }
        

    }
    return dist;
}

void subSurfScatter(inout Path path){

    int scatterSteps=1000;
    float depth=0.;
    float flowDist;

    
    Vector tv=path.tv;
    Vector temp=path.tv;
    Vector randomDir;

    
    float rough=path.dat.isotropicScatter*path.dat.isotropicScatter;
    float mfp = path.dat.meanFreePath;

    
    for (int i = 0; i < scatterSteps; i++){

        
        randomDir=randomVector(temp.pos);
        temp=mix(temp,randomDir,rough);
        
        tv=temp;
        
        flowDist=randomExponential(mfp);

        
        flow(temp,flowDist);

        
        if(!inside_Object(temp)){
            
            
            flowDist=bisect_Scatter(tv,flowDist);
            
            flow(tv,flowDist-EPSILON/2.);
            
            path.tv=tv;
            path.distance=depth+flowDist;
            path.numScatters=float(i);
            path.subSurface=false;
            return;
        }

        
        
        tv=temp;
        depth+=flowDist;

        
        roulette(path);
        if(!path.keepGoing){
            break;
        }

    }

    
    path.numScatters=float(scatterSteps);
    path.distance=depth;
    path.keepGoing=false;
}
vec3 pathTrace(Path path){

        maxBounces=50;

        for (int bounceIndex = 0; bounceIndex < maxBounces; ++bounceIndex)
        {
                
                stepForward(path);

                
                focusCheck(path);

                
                updateFromVolume(path);

                
                updateFromSky(path);

                
                scatter(path);

                if(path.subSurface){
                       
                        
                        
                        subSurfScatter(path);

                        
                        updateFromSubSurf(path);

                        
                        path.absorb=path.dat.reflectAbsorb;

                        
                        
                        

                        
                        setData_Scene(path);
                        nudge(path.tv, path.dat.normal,-5.*EPSILON);

                }
                else{
                        
                        updateFromSurface(path);
                }

                
                roulette(path);

                if(!path.keepGoing){ break; }

        }

        return path.pixel;

}

vec3 newFrame(vec2 fragCoord ){

    
    float rand = floor(1000.*randomFloat());
    seed = randomSeed(fragCoord, frameNumber+rand);

    
    Camera cam=buildCamFromUniforms();

    
    Vector tv=cameraRay(fragCoord, cam);
    Path path=initializePath(tv);

    
    buildScene();

    
    vec3 col = pathTrace(path);
    float adjust = 1.;
    
    return adjust * exposure * col;

}

void main() {
    int iter=10;
    vec3 pixel=vec3(0);
    
    pixel += newFrame(gl_FragCoord.xy);
    
    
    gl_FragColor=vec4(pixel, 1.);
}`;const Zf=new co().load("/assets/office.jpg"),Kf=new co().load("/assets/office.jpg");let Jf=function(i,t){let e="";for(let s in i)e=e.concat(i[s]);let n=$f.concat(e).concat(jf),r=t.location,a=t.uiParams,o={iResolution:{value:new L(window.innerWidth,window.innerHeight,0)},frameNumber:{value:0},sky:{value:Zf},skySM:{value:Kf},facing:{value:new Ct().set(r.facing[0],r.facing[1],r.facing[2],r.facing[3],r.facing[4],r.facing[5],r.facing[6],r.facing[7],r.facing[8])},location:{value:new L(r.position[0],r.position[1],r.position[2])},aperture:{value:a.aperture},focalLength:{value:a.focalLength},exposure:{value:a.exposure},focusHelp:{value:!1},fov:{value:a.fov},extra:{value:a.extra},extra2:{value:a.extra2},extra3:{value:a.extra3},extra4:{value:a.extra4},renderPanel:{value:!1},numPanels:{value:1},panelToRender:{value:0}};return{shader:n,uniforms:o}};var Qf=`bool render_Environment=true;

Sphere light;

Plane bottomWall, topWall, leftWall, rightWall, backWall, frontWall;

void buildEnvironment(){

    vec3 lightColor;
    float lightIntensity;

    
    light.center=vec3(-6,3,0);
    light.radius=1.;
    lightColor= vec3(0.9);
    lightIntensity=150.;
    light.mat=makeLight(lightColor,lightIntensity);

    
    
    

    Vector orientation;
    vec3 color=0.15*vec3(171,203,240)/255.;
    float specularity=0.;
    float roughness=0.1;

    
    orientation.pos=vec3(0,-1.15,0);
    orientation.dir=vec3(0,1,0);
    bottomWall.orientation=orientation;
    bottomWall.mat=makeDielectric(color,0.0,roughness);

    
    orientation.pos=vec3(0,14,0);
    orientation.dir=vec3(0,-1,0);
    topWall.orientation=orientation;
    topWall.mat=makeLight(vec3(1,1,1),1.*extra4);

    
    orientation.pos=vec3(0,0,-20);
    orientation.dir=vec3(0,0,1);
    frontWall.orientation=orientation;
    frontWall.mat=makeDielectric(color,0.0,roughness);

    
    orientation.pos=vec3(0,0,10);
    orientation.dir=vec3(0,0,-1);
    backWall.orientation=orientation;
    backWall.mat=makeDielectric(color,0.0,roughness);

    
    orientation.pos=vec3(-20,0,0);
    orientation.dir=vec3(1,0,0);
    leftWall.orientation=orientation;
    leftWall.mat=makeDielectric(color,0.0,roughness);

    
    orientation.pos=vec3(8.5,0,0);
    orientation.dir=vec3(-1,0,0);
    rightWall.orientation=orientation;
    rightWall.mat=makeDielectric(color,0.0,roughness);

}

float trace_Environment(Vector tv ){

    float dist=maxDist;

    dist = min(dist, trace(tv,light));

    dist=min(dist, trace(tv, bottomWall));
    dist=min(dist, trace(tv, topWall));
    dist=min(dist, trace(tv, frontWall));
    dist=min(dist, trace(tv, backWall));
    dist=min(dist, trace(tv, leftWall));
    dist=min(dist, trace(tv, rightWall));

    return dist;

}

float sdf_Environment(Vector tv ){

    float dist=maxDist;

    

    return dist;

}

void setData_Environment( inout Path path ){

    setData(path, light);

    setData(path, bottomWall);

    setData(path, topWall);

    setData(path, frontWall);

    setData(path, backWall);

    setData(path, leftWall);

    setData(path, rightWall);

}`,tp=`struct Bottle{
    vec3 center;
    float baseRadius;
    float baseHeight;
    float neckRadius;
    float neckHeight;
    float thickness;
    float rounded;
    float smoothJoin;
    float bump;
    Material mat;
    Sphere boundingBox;
};

float bottleDistance(vec3 p, Bottle bottle,out float insideBottle ){

    vec3 pos=p-bottle.center;

    
    float base=cylinderDist(pos,bottle.baseRadius, bottle.baseHeight,bottle.rounded);

    
    
    vec3 q=pos-vec3(0,bottle.baseHeight+bottle.neckHeight,0);

    float neck=cylinderDist(q,bottle.neckRadius,bottle.neckHeight,bottle.rounded);

    
    float theBottle=opMinDist(base, neck,bottle.smoothJoin);

    if(bottle.bump!=0.){
        vec3 r=pos+vec3(0,bottle.baseHeight,0.);
        float bump=length(r)-0.25;
        theBottle=opMaxDist(theBottle,-bump,1.);
    }

    insideBottle=theBottle+bottle.thickness;

    
    theBottle=opOnionDist(theBottle,bottle.thickness);

    
    float top=q.y-bottle.neckHeight/3.;

    theBottle=opMaxDist(theBottle,top,bottle.thickness);

    return theBottle;

}

float distR3(vec3 pos, Bottle bottle){
    return bottleDistance(pos,bottle,trashFloat);
}

float sdf(Vector tv, Bottle bottle){

    
    
    
    
    
    
    

    
    return distR3(tv.pos, bottle);
}

Vector normalVec(Vector tv, Bottle bottle){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, bottle);
    float vyyx=distR3( pos + e.yyx*ep, bottle);
    float vyxy=distR3( pos + e.yxy*ep, bottle);
    float vxxx=distR3( pos + e.xxx*ep, bottle);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}

bool at( Vector tv, Bottle bottle){

    float d = distR3( tv.pos, bottle );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

bool inside( Vector tv, Bottle bottle ){
    float d = distR3( tv.pos, bottle );
    return (d<0.);
}

void setData( inout Path path, Bottle bottle ){

    
    if(at(path.tv, bottle)){
        
        Vector normal=normalVec(path.tv,bottle);
        bool side = inside(path.tv, bottle);
        
        setObjectInAir(path.dat, side, normal, bottle.mat);
    }

}

Bottle bottle;

void buildObjects(){

    bottle.center=vec3(1,0.48,2);
    bottle.baseHeight=1.5;
    bottle.baseRadius=1.25;
    bottle.neckHeight=1.;
    bottle.neckRadius=0.3;
    bottle.thickness=0.1;
    bottle.rounded=0.1;
    bottle.smoothJoin=0.3;
    bottle.bump=1.;

    vec3 purpleScatter = vec3(0.25,0.65,0.4);
    vec3 greenGlass = vec3(0.3,0.05,0.2);

    bottle.mat=makeGlass(1.5*purpleScatter,1.5,0.95);
    bottle.mat.refractionChance=0.;
    bottle.mat.subSurface=true;
    bottle.mat.meanFreePath=0.5*extra2;
    bottle.mat.isotropicScatter=extra;
    bottle.mat.roughness=0.0;

    
    bottle.boundingBox.center=bottle.center;
    bottle.boundingBox.radius=bottle.baseHeight+bottle.neckHeight+0.5;

}

bool render_Objects=true;

float trace_Objects( Vector tv ){
    float dist=maxDist;
    return dist;
}

float sdf_Objects( Vector tv ){

    float dist=maxDist;
    dist=min( dist, sdf(tv, bottle) );

    return dist;
}

bool inside_Object( Vector tv ){
    return inside(tv,bottle);
}

void setData_Objects(inout Path path){
    setData(path, bottle);
}`;let ep={aperture:0,focalLength:14.92,exposure:1,focusHelp:!1,fov:62,extra:.73,extra2:.84,extra3:.368,extra4:.5},np=[-2.920570474892029,5.440804593985878,10.275012381895698],ip=[.8333690207748797,.06840206413805923,-.5484680782271459,.06646440183394467,.9727101064037655,.222300544733267,.5487062588502066,-.22171199002647812,.8060801665944561],rp={position:np,facing:ip};const uo={uiParams:ep,location:rp};let ap=typeof type<"u"&&type&&!isNaN(type)?parseInt(type):0,Xi=new ri;Xi.showPanel(ap);document.body.appendChild(Xi.dom);let sp={environment:Qf,objects:tp},op=Jf(sp,uo),lp={tracer:op,accumulate:Xf,display:Yf},ho=new Uf(lp,uo);new kf(ho);function fo(){requestAnimationFrame(fo),Xi.begin(),ho.newFrame(),Xi.end()}fo();
