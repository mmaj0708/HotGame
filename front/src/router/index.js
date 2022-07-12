import Vue from 'vue'
import VueRouter from 'vue-router'
import LandingPage from '../views/LandingPage.vue'
import BrowserPage from '../views/Browser.vue'
import CreatePage from '../views/CreatePage.vue'
import HistoryPage from '../views/HistoryPage.vue'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'LandingPage',
    component: LandingPage
  },
  {
    path: '/browser',
    name: 'browser',
    component: BrowserPage
  },
  {
    path: '/create',
    name: 'create',
    component: CreatePage
  },
  {
    path: '/history',
    name: 'history',
    component: HistoryPage
  },
  {
    path: '/about',
    name: 'about',
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    component: () => import(/* webpackChunkName: "about" */ '../views/AboutView.vue')
  }
]

const router = new VueRouter({
  mode: 'history',
  routes
})

export default router
