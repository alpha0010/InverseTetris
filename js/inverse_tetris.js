(function(){function n(b,a){return function(){return b.apply(a,arguments)}}var l;l=function(){function b(a){this.L=n(this.L,this);this.M=n(this.M,this);this.v=n(this.v,this);this.B=n(this.B,this);var e,c,d,h,b,g=this;e=Math.min(((window.innerWidth||document.documentElement.clientWidth||document.body.clientWidth)-20)/(this.h+this.P)-1,((window.innerHeight||document.documentElement.clientHeight||document.body.clientHeight)-20)/(this.o+this.G)-1);this.b=e>this.b?Math.floor((e+this.b)/2):Math.floor(e); e=document.getElementById("gameBoard");e.width=(this.b+1)*(this.h+this.P)+1;e.height=(this.b+1)*(this.o+this.G)+1;this.a=e.getContext("2d");this.a.fillStyle="rgb(38,38,38)";this.a.strokeStyle="transparent";this.a.fillRect(0,0,e.width,e.height);this.fa();this.ea();this.k=Math.floor(7*Math.random());this.q=this.s(this.l[this.k]);this.ga();this.N=e.getBoundingClientRect();e.addEventListener("mousemove",function(a){return g.M(a)});e.addEventListener("mouseup",function(a){return g.L(a)});e=[];b=this.l; d=0;for(h=b.length;d<h;d++)c=b[d],e.push(this.s(c));a.da(e);this.D=a;this.B()}b.prototype.j=null;b.prototype.b=25;b.prototype.o=20;b.prototype.h=10;b.prototype.P=5;b.prototype.G=4;b.prototype.C=175;b.prototype.T=15;b.prototype.a=null;b.prototype.l=null;b.prototype.c=null;b.prototype.q=null;b.prototype.k=null;b.prototype.D=null;b.prototype.Q=0;b.prototype.r=0;b.prototype.N=null;b.prototype.n=-1;b.prototype.f=null;b.prototype.fa=function(){this.l=[[[0,255,255],2,[1,1,1,1]],[[0,0,255],4,[1,1,1],[0,0, 1]],[[255,165,0],4,[1,1,1],[1,0,0]],[[255,255,0],1,[1,1],[1,1]],[[128,255,0],2,[0,1,1],[1,1,0]],[[128,0,128],4,[1,1,1],[0,1,0]],[[255,0,255],2,[1,1,0],[0,1,1]]]};b.prototype.ea=function(){var a,e,c,d,b,f,g;this.j=[];c=d=0;for(f=this.o;0<=f?d<f:d>f;c=0<=f?++d:--d)for(this.j[c]=[],e=b=0,g=this.h;0<=g?b<g:b>g;e=0<=g?++b:--b)a={i:!1,fillStyle:null},this.j[c][e]=a};b.prototype.ga=function(){var a,e,c,d;this.f=[];a=this.b/2;e=c=0;for(d=this.l.length;0<=d?c<d:c>d;e=0<=d?++c:--c)this.f.push({x:(1+e%4*5)* (a+1)+1,y:(2*this.o+(3<e?3:0))*(a+1)+1,count:4})};b.prototype.p=function(a){var e,c,d,b,f,g,k;c=[];d=b=0;for(g=a.length;0<=g?b<g:b>g;d=0<=g?++b:--b)for(e=f=0,k=a[d].length;0<=k?f<k:f>k;e=0<=k?++f:--f)0===d&&(c[e]=[]),c[e][d]=a[a.length-d-1][e];return c};b.prototype.B=function(){var a,e,c,d,b,f,g,k;if(null===this.c){if(null===this.q){if(0.7>Math.random())for(a=Number.MAX_VALUE,c=d=0,b=this.f.length;0<=b?d<b:d>b;c=0<=b?++d:--d)0<this.f[c].count&&(e=this.D.ja(this.j,this.s(this.l[c])),e<a&&(a=e,this.k= c));else for(this.k=Math.floor(7*Math.random());0===this.f[this.k].count;)this.k=(this.k+1)%7;this.q=this.s(this.l[this.k])}this.c=this.q;this.f[this.k].count-=1;a=e=!0;f=this.f;d=0;for(b=f.length;d<b;d++)c=f[d],1<c.count&&(e=!1),c.count!==this.f[this.k].count&&(a=!1);if(a)for(d=this.f,a=0,e=d.length;a<e;a++)c=d[a],c.count=4;else if(e)for(d=this.f,a=0,e=d.length;a<e;a++)c=d[a],c.count+=2;-1!==this.n&&0>=this.f[this.n].count&&(this.n=-1);this.k=-1;this.q=null;this.V();this.J();this.C=175}if(this.m(this.c.g+ 1,this.c.e)){if(-1===this.c.g)return;this.Z();this.c=null;a=0;k=this.j;f=0;for(d=k.length;f<d;f++)for(e=k[f],g=0,b=e.length;g<b;g++)c=e[g],c.i&&(a+=1);this.r+=1;this.Q+=Math.floor(4*Math.pow(a,0.6))/4}else this.c.g+=1;this.t();setTimeout(this.B,this.C);return setTimeout(this.v,this.T)};b.prototype.v=function(){var a;if(null!==this.c){a=this.D.aa(this.j,this.c);switch(a){case 1:this.ha();break;case 2:this.ia();break;case 3:this.ka();break;case 4:this.la();break;default:this.C=Math.max(64,175-this.r); return}this.C=175;return setTimeout(this.v,this.T)}};b.prototype.M=function(a){var e,c,d,b,f;c=a.clientX-this.N.left;d=a.clientY-this.N.top;a=b=0;for(f=this.f.length;0<=f?b<f:b>f;a=0<=f?++b:--b)if(e=this.f[a],c>e.x&&c<e.x+2*this.b&&d>e.y&&d<e.y+this.b){0>=this.f[a].count&&(a=-1);this.n!==a&&(this.n=a,this.J());return}-1!==this.n&&(this.n=-1,this.J())};b.prototype.L=function(){-1!==this.n&&(this.q=this.s(this.l[this.n]),this.k=this.n,this.V())};b.prototype.m=function(a,e){var c,d,b,f,g,k;d=b=0;for(g= this.c.d.length;0<=g?b<g:b>g;d=0<=g?++b:--b){if(0>a+d||a+d>=this.o)return!0;c=f=0;for(k=this.c.d[d].length;0<=k?f<k:f>k;c=0<=k?++f:--f)if(0>e+c||e+c>=this.h||1===this.c.d[d][c]&&this.j[a+d][e+c].i)return!0}return!1};b.prototype.s=function(a){return{g:-1,e:Math.floor((this.h-a[2].length)/2),fillStyle:"rgb("+a[0][0]+","+a[0][1]+","+a[0][2]+")",W:a[1],d:a.slice(2)}};b.prototype.Z=function(){var a,e,c,d,b,f,g;c=this.c.d;e=d=0;for(f=c.length;0<=f?d<f:d>f;e=0<=f?++d:--d)for(a=b=0,g=c[e].length;0<=g?b<g: b>g;a=0<=g?++b:--b)1===c[e][a]&&(a=this.j[e+this.c.g][a+this.c.e],a.i=!0,a.fillStyle=this.c.fillStyle);this.I()};b.prototype.I=function(){var a,e,c;a=e=0;for(c=this.o;0<=c?e<c:e>c;a=0<=c?++e:--e)this.F(this.j[a])&&this.O(a)};b.prototype.F=function(a){var e,c,d;c=0;for(d=a.length;c<d;c++)if(e=a[c],!e.i)return!1;return!0};b.prototype.O=function(a){var e,c;this.j.splice(a,1);this.j.splice(0,0,[]);a=e=0;for(c=this.h;0<=c?e<c:e>c;a=0<=c?++e:--e)this.j[0][a]={i:!1,fillStyle:null}};b.prototype.t=function(){var a, e,c,d,b,f,g,k;e=c=0;for(b=this.o;0<=b?c<b:c>b;e=0<=b?++c:--c)for(a=d=0,f=this.h;0<=f?d<f:d>f;a=0<=f?++d:--d)this.w(this.j[e][a],e,a);if(null!==this.c)for(a={i:!1,fillStyle:null,i:!0},a.fillStyle=this.c.fillStyle,e=this.c.d,d=b=0,g=e.length;0<=g?b<g:b>g;d=0<=g?++b:--b)for(c=f=0,k=e[d].length;0<=k?f<k:f>k;c=0<=k?++f:--f)1===e[d][c]&&this.w(a,this.c.g+d,this.c.e+c)};b.prototype.V=function(){var a,e,c,b,h,f,g,k;this.a.fillStyle="rgb(38,38,38)";this.a.strokeStyle="transparent";this.a.fillRect(this.h*(this.b+ 1)+1,0,this.P*(this.b+1),this.o*(this.b+1));this.ca();if(null===this.q)this.a.font=""+this.b+"px Arial",this.a.fillStyle="white",this.a.fillText("???",(this.h+1.25)*(this.b+1),2.25*(this.b+1));else for(a={i:!1,fillStyle:null,i:!0},a.fillStyle=this.q.fillStyle,e=this.q.d,b=h=0,g=e.length;0<=g?h<g:h>g;b=0<=g?++h:--h)for(c=f=0,k=e[b].length;0<=k?f<k:f>k;c=0<=k?++f:--f)1===e[b][c]&&this.w(a,1+b,this.h+1+c)};b.prototype.J=function(){var a,e,c,b,h,f,g,k,l,p,m,n,r;this.a.fillStyle="rgb(38,38,38)";this.a.strokeStyle= "transparent";this.a.fillRect(0,this.o*(this.b+1)+1,this.h*(this.b+1),this.G*(this.b+1));c=this.b;this.b/=2;b=k=0;for(m=this.l.length;0<=m?k<m:k>m;b=0<=m?++k:--k){a=this.l[b];e={i:!1,fillStyle:null,i:!0};e.fillStyle=0<this.f[b].count?"rgb("+a[0][0]+","+a[0][1]+","+a[0][2]+")":"gray";g="transparent";b===this.n&&(g="red");a=a.slice(2);f=l=0;for(n=a.length;0<=n?l<n:l>n;f=0<=n?++l:--l)for(h=p=0,r=a[f].length;0<=r?p<r:p>r;h=0<=r?++p:--p)1===a[f][h]&&this.w(e,2*this.o+f+(3<b?3:0),1+h+b%4*5,g);this.a.font= ""+this.b+"px Arial";this.a.fillStyle="white";this.a.fillText(this.f[b].count,this.f[b].x,this.f[b].y-1)}this.b=c};b.prototype.ca=function(){this.a.font=""+this.b+"px Arial";this.a.fillStyle="white";this.a.fillText("Score",(this.h+0.5)*(this.b+1),5*(this.b+1));0<this.r&&this.a.fillText(Math.round(1E3*this.Q/this.r),(this.h+0.5)*(this.b+1),6*(this.b+1));this.a.fillText("Blocks",(this.h+0.5)*(this.b+1),7.4*(this.b+1));this.a.fillText(this.r,(this.h+0.5)*(this.b+1),8.4*(this.b+1))};b.prototype.w=function(a, b,c,d){var h;null==d&&(d="rgb(54,51,40)");c=c*(this.b+1)+1;b=b*(this.b+1)+1;h=a.i?a.fillStyle:"rgb(38,38,38)";this.a.strokeStyle=d;this.a.strokeRect(c,b,this.b,this.b);this.a.fillStyle=h;this.a.fillRect(c,b,this.b,this.b);a.i&&(a=this.b/4,this.a.beginPath(),this.a.moveTo(c,b+this.b),this.a.lineTo(c+this.b,b+this.b),this.a.lineTo(c+this.b-a,b+this.b-a),this.a.lineTo(c+a,b+this.b-a),this.a.closePath(),d=this.a.createLinearGradient(c,b+this.b-a,c,b+this.b),d.addColorStop(0,"rgba(0,0,0,0)"),d.addColorStop(1, "rgba(0,0,0,0.5)"),this.a.fillStyle=d,this.a.fill(),this.a.beginPath(),this.a.moveTo(c+this.b,b),this.a.lineTo(c+this.b,b+this.b),this.a.lineTo(c+this.b-a,b+this.b-a),this.a.lineTo(c+this.b-a,b+a),this.a.closePath(),d=this.a.createLinearGradient(c+this.b-a,b,c+this.b,b),d.addColorStop(0,"rgba(0,0,0,0)"),d.addColorStop(1,"rgba(0,0,0,0.5)"),this.a.fillStyle=d,this.a.fill(),this.a.beginPath(),this.a.moveTo(c,b),this.a.lineTo(c+this.b,b),this.a.lineTo(c+this.b-a,b+a),this.a.lineTo(c+a,b+a),this.a.closePath(), d=this.a.createLinearGradient(c,b+a,c,b),d.addColorStop(0,"rgba(255,255,255,0)"),d.addColorStop(1,"rgba(255,255,255,0.4)"),this.a.fillStyle=d,this.a.fill(),this.a.beginPath(),this.a.moveTo(c,b),this.a.lineTo(c,b+this.b),this.a.lineTo(c+a,b+this.b-a),this.a.lineTo(c+a,b+a),this.a.closePath(),d=this.a.createLinearGradient(c+a,b,c,b),d.addColorStop(0,"rgba(255,255,255,0)"),d.addColorStop(1,"rgba(255,255,255,0.4)"),this.a.fillStyle=d,this.a.fill(),a=this.b/6,this.a.beginPath(),this.a.moveTo(c+a,b),this.a.quadraticCurveTo(c, b,c,b+a),this.a.lineTo(c,b),this.a.closePath(),this.a.fillStyle="rgb(38,38,38)",this.a.fill(),this.a.beginPath(),this.a.moveTo(c+this.b-a,b),this.a.quadraticCurveTo(c+this.b,b,c+this.b,b+a),this.a.lineTo(c+this.b,b),this.a.closePath(),this.a.fill(),this.a.beginPath(),this.a.moveTo(c,b+this.b-a),this.a.quadraticCurveTo(c,b+this.b,c+a,b+this.b),this.a.lineTo(c,b+this.b),this.a.closePath(),this.a.fill(),this.a.beginPath(),this.a.moveTo(c+this.b,b+this.b-a),this.a.quadraticCurveTo(c+this.b,b+this.b,c+ this.b-a,b+this.b),this.a.lineTo(c+this.b,b+this.b),this.a.closePath(),this.a.fill())};b.prototype.ha=function(){null===this.c||this.m(this.c.g,this.c.e-1)||(this.c.e-=1,this.t())};b.prototype.ia=function(){null===this.c||this.m(this.c.g,this.c.e+1)||(this.c.e+=1,this.t())};b.prototype.ka=function(){var a;null!==this.c&&(a=this.c.d,this.c.d=this.p(this.p(this.p(this.c.d))),this.m(this.c.g,this.c.e)?this.c.d=a:this.t())};b.prototype.la=function(){var a;null!==this.c&&(a=this.c.d,this.c.d=this.p(this.c.d), this.m(this.c.g,this.c.e)?this.c.d=a:this.t())};return b}();window.InverseTetris=l}).call(this);
