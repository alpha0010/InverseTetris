(function(){var n;n=function(){function l(b){this.K=b}l.prototype.l=null;l.prototype.A=null;l.prototype.K=0;l.prototype.da=function(b){this.l=b;this.A={}};l.prototype.aa=function(b,a){return this.H(this.U(b),a)[0]};l.prototype.ja=function(b,a){return this.H(this.U(b),a,this.K-1)[1]};l.prototype.H=function(b,a,e){var c,d,h,f;null==e&&(e=0);h=this.ba(a);d=this.u(b,h,e);c=0;f=this.R(b,h,e);f<d&&(d=f,c=1);h.e=a.e;f=this.S(b,h,e);f<d&&(d=f,c=2);1<a.W&&(f=this.ma(b,h,e),f<d&&(d=f,c=3),2<a.W&&(f=this.Y(b, h,e),f<Number.MAX_VALUE&&(a=h.d,h.d=this.p(h.d),f=Math.min(f,this.Y(b,h,e)),h.d=a),f<d&&(d=f,c=4)));return[c,d]};l.prototype.ma=function(b,a,e){var c,d,h;h=a.d;d=a.e;c=Number.MAX_VALUE;a.d=this.p(this.p(this.p(a.d)));this.m(b,a,a.g,a.e)||(c=this.u(b,a,e),c=Math.min(c,this.S(b,a,e)),a.e=d,c=Math.min(c,this.R(b,a,e)));a.e=d;a.d=h;return c};l.prototype.Y=function(b,a,e){var c,d,h;h=a.d;d=a.e;c=Number.MAX_VALUE;a.d=this.p(a.d);this.m(b,a,a.g,a.e)||(c=this.u(b,a,e),c=Math.min(c,this.S(b,a,e)),a.e=d,c= Math.min(c,this.R(b,a,e)));a.e=d;a.d=h;return c};l.prototype.R=function(b,a,e){var c;for(c=Number.MAX_VALUE;0<a.e;){a.e-=1;if(this.m(b,a,a.g,a.e))break;c=Math.min(c,this.u(b,a,e))}return c};l.prototype.S=function(b,a,e){var c;for(c=Number.MAX_VALUE;a.e+a.d[0].length<b[0].length;){a.e+=1;if(this.m(b,a,a.g,a.e))break;c=Math.min(c,this.u(b,a,e))}return c};l.prototype.p=function(b){var a,e,c,d,h,f,g;e=[];c=d=0;for(f=b.length;0<=f?d<f:d>f;c=0<=f?++d:--d)for(a=h=0,g=b[c].length;0<=g?h<g:h>g;a=0<=g?++h: --h)0===c&&(e[a]=[]),e[a][c]=b[b.length-c-1][a];return e};l.prototype.U=function(b){var a,e,c,d,h,f,g;e=[];c=d=0;for(f=b.length;0<=f?d<f:d>f;c=0<=f?++d:--d)for(e[c]=[],a=h=0,g=b[c].length;0<=g?h<g:h>g;a=0<=g?++h:--h)e[c][a]=b[c][a].i;return e};l.prototype.ba=function(b){var a,e,c,d,h,f,g;e={g:Math.max(0,b.g),e:b.e,d:null,d:[]};c=d=0;for(f=b.d.length;0<=f?d<f:d>f;c=0<=f?++d:--d)for(e.d[c]=[],a=h=0,g=b.d[c].length;0<=g?h<g:h>g;a=0<=g?++h:--h)e.d[c][a]=1===b.d[c][a];return e};l.prototype.u=function(b, a,e){var c,d,h,f,g,k,q;if(e>=this.K)return this.evaluate(this.X(b,a));a=this.X(b,a);b="";if(0===e){f=0;for(k=a.length;f<k;f++){d=a[f];g=h=0;for(q=d.length;g<q;g++)c=d[g],h*=2,c&&(h+=1);0<b.length?b+="|"+h:0<h&&(b+=h)}if(this.A.hasOwnProperty(b))return this.A[b]}d=Number.MIN_VALUE;g=this.l;h=0;for(f=g.length;h<f;h++)c=g[h],d=Math.max(d,this.H(a,c,e+1)[1]);0===e&&(this.A[b]=d);return d};l.prototype.X=function(b,a){var e,c,d,h,f,g,k,q,l,m;for(c=0;!this.m(b,a,a.g+c+1,a.e);)++c;d=[];h=g=0;for(l=b.length;0<= l?g<l:g>l;h=0<=l?++g:--g)for(d[h]=[],e=k=0,m=b[h].length;0<=m?k<m:k>m;e=0<=m?++k:--k)d[h][e]=b[h][e];h=g=0;for(l=a.d.length;0<=l?g<l:g>l;h=0<=l?++g:--g)for(e=k=0,m=a.d[h].length;0<=m?k<m:k>m;e=0<=m?++k:--k)(f=d[h+a.g+c])[q=e+a.e]||(f[q]=a.d[h][e]);this.I(d);return d};l.prototype.m=function(b,a,e,c){var d,h,f,g,k,l;h=f=0;for(k=a.d.length;0<=k?f<k:f>k;h=0<=k?++f:--f){if(0>e+h||e+h>=b.length)return!0;d=g=0;for(l=a.d[h].length;0<=l?g<l:g>l;d=0<=l?++g:--g)if(0>c+d||c+d>=b[0].length||a.d[h][d]&&b[e+h][c+ d])return!0}return!1};l.prototype.evaluate=function(b){var a,e,c,d,h,f,g,k,l,p;d=c=h=0;for(k=b.length;0<=k?c<k:c>k;d=0<=k?++c:--c)for(a=f=0,l=b[d].length;0<=l?f<l:f>l;a=0<=l?++f:--f)if(b[d][a])h+=(b.length-d+2)/2*this.$(a,b[d].length),d<b.length-3&&(h+=(b.length-d+6)/8);else if(0<d&&b[d-1][a])for(h+=18,e=g=d,p=b.length;(d<=p?g<p:g>p)&&!b[e][a];e=d<=p?++g:--g)h+=1;a=f=0;for(k=b[0].length;0<=k?f<k:f>k;a=0<=k?++f:--f){e=0;c=-1;d=g=0;for(l=b.length;0<=l?g<l:g>l;d=0<=l?++g:--g)b[d][a]||0!==a&&!b[d][a- 1]||a!==b[0].length-1&&!b[d][a+1]||(-1===c&&(c=d),++e);1<e&&(h+=e*(b.length-c+3)/4)}return h};l.prototype.$=function(b,a){return(((b>a/2?a-b-1:b)+2)/(a+2)+2)/2};l.prototype.I=function(b){var a,e,c;a=e=0;for(c=b.length;0<=c?e<c:e>c;a=0<=c?++e:--e)this.F(b[a])&&this.O(b,a)};l.prototype.F=function(b){var a,e,c;e=0;for(c=b.length;e<c;e++)if(a=b[e],!a)return!1;return!0};l.prototype.O=function(b,a){var e,c,d;b.splice(a,1);b.splice(0,0,[]);e=c=0;for(d=b[1].length;0<=d?c<d:c>d;e=0<=d?++c:--c)b[0][e]=!1}; return l}();window.TetrisAI=n}).call(this);
