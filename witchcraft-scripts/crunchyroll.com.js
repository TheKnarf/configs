const H=function(){const t=document.createElement("link").relList;if(t&&t.supports&&t.supports("modulepreload"))return;for(const l of document.querySelectorAll('link[rel="modulepreload"]'))s(l);new MutationObserver(l=>{for(const i of l)if(i.type==="childList")for(const o of i.addedNodes)o.tagName==="LINK"&&o.rel==="modulepreload"&&s(o)}).observe(document,{childList:!0,subtree:!0});function n(l){const i={};return l.integrity&&(i.integrity=l.integrity),l.referrerpolicy&&(i.referrerPolicy=l.referrerpolicy),l.crossorigin==="use-credentials"?i.credentials="include":l.crossorigin==="anonymous"?i.credentials="omit":i.credentials="same-origin",i}function s(l){if(l.ep)return;l.ep=!0;const i=n(l);fetch(l.href,i)}};H();let K=I;const A={},g=1,S=2,v={owned:null,cleanups:null,context:null,owner:null};var r=null;let C=null,p=null,y=null,u=null,h=null,E=0;function V(e,t){t&&(r=t);const n=p,s=r,l=e.length===0?v:{owned:null,cleanups:null,context:null,owner:s};r=l,p=null;let i;try{T(()=>i=e(()=>P(l)),!0)}finally{p=n,r=s}return i}function N(e,t,n){const s=J(e,t,!1,g);U(s)}function W(e){if(y)return e();let t;const n=y=[];try{t=e()}finally{y=null}return T(()=>{for(let s=0;s<n.length;s+=1){const l=n[s];if(l.pending!==A){const i=l.pending;l.pending=A,O(l,i)}}},!1),t}function q(e){let t,n=p;return p=null,t=e(),p=n,t}function O(e,t,n){if(e.comparator&&e.comparator(e.value,t))return t;if(y)return e.pending===A&&y.push(e),e.pending=t,t;let s=!1;return e.value=t,e.observers&&e.observers.length&&T(()=>{for(let l=0;l<e.observers.length;l+=1){const i=e.observers[l];s&&C.disposed.has(i),i.pure?u.push(i):h.push(i),i.observers&&(s&&!i.tState||!s&&!i.state)&&R(i),s||(i.state=g)}if(u.length>1e6)throw u=[],new Error},!1),t}function U(e){if(!e.fn)return;P(e);const t=r,n=p,s=E;p=r=e,j(e,e.value,s),p=n,r=t}function j(e,t,n){let s;try{s=e.fn(t)}catch(l){_(l)}(!e.updatedAt||e.updatedAt<=n)&&(e.observers&&e.observers.length?O(e,s):e.value=s,e.updatedAt=n)}function J(e,t,n,s=g,l){const i={fn:e,state:s,updatedAt:null,owned:null,sources:null,sourceSlots:null,cleanups:null,value:t,owner:r,context:null,pure:n};return r===null||r!==v&&(r.owned?r.owned.push(i):r.owned=[i]),i}function D(e){const t=C;if(e.state!==g)return e.state=0;if(e.suspense&&q(e.suspense.inFallback))return e.suspense.effects.push(e);const n=[e];for(;(e=e.owner)&&(!e.updatedAt||e.updatedAt<E);)(e.state||t)&&n.push(e);for(let s=n.length-1;s>=0;s--)if(e=n[s],e.state===g||t)U(e);else if(e.state===S||t){const l=u;u=null,M(e),u=l}}function T(e,t){if(u)return e();let n=!1;t||(u=[]),h?n=!0:h=[],E++;try{e()}catch(s){_(s)}finally{X(n)}}function X(e){u&&(I(u),u=null),!e&&(h.length?W(()=>{K(h),h=null}):h=null)}function I(e){for(let t=0;t<e.length;t++)D(e[t])}function M(e){e.state=0;const t=C;for(let n=0;n<e.sources.length;n+=1){const s=e.sources[n];s.sources&&(s.state===g||t?D(s):(s.state===S||t)&&M(s))}}function R(e){const t=C;for(let n=0;n<e.observers.length;n+=1){const s=e.observers[n];(!s.state||t)&&(s.state=S,s.pure?u.push(s):h.push(s),s.observers&&R(s))}}function P(e){let t;if(e.sources)for(;e.sources.length;){const n=e.sources.pop(),s=e.sourceSlots.pop(),l=n.observers;if(l&&l.length){const i=l.pop(),o=n.observerSlots.pop();s<l.length&&(i.sourceSlots[o]=s,l[s]=i,n.observerSlots[s]=o)}}if(e.owned){for(t=0;t<e.owned.length;t++)P(e.owned[t]);e.owned=null}if(e.cleanups){for(t=0;t<e.cleanups.length;t++)e.cleanups[t]();e.cleanups=null}e.state=0,e.context=null}function _(e){throw e}function Y(e,t){return q(()=>e(t))}function $(e,t,n){let s=n.length,l=t.length,i=s,o=0,f=0,m=t[l-1].nextSibling,a=null;for(;o<l||f<i;){if(t[o]===n[f]){o++,f++;continue}for(;t[l-1]===n[i-1];)l--,i--;if(l===o){const c=i<s?f?n[f-1].nextSibling:n[i-f]:m;for(;f<i;)e.insertBefore(n[f++],c)}else if(i===f)for(;o<l;)(!a||!a.has(t[o]))&&e.removeChild(t[o]),o++;else if(t[o]===n[i-1]&&n[f]===t[l-1]){const c=t[--l].nextSibling;e.insertBefore(n[f++],t[o++].nextSibling),e.insertBefore(n[--i],c),t[l]=n[i]}else{if(!a){a=new Map;let d=f;for(;d<i;)a.set(n[d],d++)}const c=a.get(t[o]);if(c!=null)if(f<c&&c<i){let d=o,b=1,B;for(;++d<l&&d<i&&!((B=a.get(t[d]))==null||B!==c+b);)b++;if(b>c-f){const Q=t[o];for(;f<c;)e.insertBefore(n[f++],Q)}else e.replaceChild(n[f++],t[o++])}else o++;else e.removeChild(t[o++])}}}function Z(e,t,n){let s;return V(l=>{s=l,F(t,e(),t.firstChild?null:void 0,n)}),()=>{s(),t.textContent=""}}function k(e,t,n){const s=document.createElement("template");s.innerHTML=e;let l=s.content.firstChild;return n&&(l=l.firstChild),l}function F(e,t,n,s){if(n!==void 0&&!s&&(s=[]),typeof t!="function")return x(e,t,s,n);N(l=>x(e,t(),l,n),s)}function x(e,t,n,s,l){for(;typeof n=="function";)n=n();if(t===n)return n;const i=typeof t,o=s!==void 0;if(e=o&&n[0]&&n[0].parentNode||e,i==="string"||i==="number")if(i==="number"&&(t=t.toString()),o){let f=n[0];f&&f.nodeType===3?f.data=t:f=document.createTextNode(t),n=w(e,n,s,f)}else n!==""&&typeof n=="string"?n=e.firstChild.data=t:n=e.textContent=t;else if(t==null||i==="boolean")n=w(e,n,s);else{if(i==="function")return N(()=>{let f=t();for(;typeof f=="function";)f=f();n=x(e,f,n,s)}),()=>n;if(Array.isArray(t)){const f=[];if(L(f,t,l))return N(()=>n=x(e,f,n,s,!0)),()=>n;if(f.length===0){if(n=w(e,n,s),o)return n}else Array.isArray(n)?n.length===0?G(e,f,s):$(e,n,f):n==null||n===""?G(e,f):$(e,o&&n||[e.firstChild],f);n=f}else if(t instanceof Node){if(Array.isArray(n)){if(o)return n=w(e,n,s,t);w(e,n,null,t)}else n==null||n===""||!e.firstChild?e.appendChild(t):e.replaceChild(t,e.firstChild);n=t}}return n}function L(e,t,n){let s=!1;for(let l=0,i=t.length;l<i;l++){let o=t[l],f;if(o instanceof Node)e.push(o);else if(!(o==null||o===!0||o===!1))if(Array.isArray(o))s=L(e,o)||s;else if((f=typeof o)==="string")e.push(document.createTextNode(o));else if(f==="function")if(n){for(;typeof o=="function";)o=o();s=L(e,Array.isArray(o)?o:[o])||s}else e.push(o),s=!0;else e.push(document.createTextNode(o.toString()))}return s}function G(e,t,n){for(let s=0,l=t.length;s<l;s++)e.insertBefore(t[s],n)}function w(e,t,n,s){if(n===void 0)return e.textContent="";const l=s||document.createTextNode("");if(t.length){let i=!1;for(let o=t.length-1;o>=0;o--){const f=t[o];if(l!==f){const m=f.parentNode===e;!i&&!o?m?e.replaceChild(l,f):e.insertBefore(l,n):m&&e.removeChild(f)}else i=!0}}else e.insertBefore(l,n);return[l]}const z=k("<div><span>Queue: </span></div>"),ee=()=>{const e=document.querySelectorAll(".queue-item-wrapper");return(()=>{const t=z.cloneNode(!0),n=t.firstChild;return n.firstChild,t.style.setProperty("padding","20px"),t.style.setProperty("background","black"),t.style.setProperty("color","white"),t.style.setProperty("font-size","22px"),t.style.setProperty("font-family","sans-serif"),t.style.setProperty("margin","20px 0"),F(n,()=>e.length,null),t})()};window.addEventListener("load",()=>{const e=document.createElement("div");document.querySelector("#tabs").parentElement.insertBefore(e,tabs.nextSibling),Z(()=>Y(ee,{}),e)});
