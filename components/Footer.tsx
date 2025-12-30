import Link from 'next/link'
import Logo from './Logo'

export default function Footer() {
  return (
    <footer className="bg-gray-900 text-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-8">
          {/* Brand */}
          <div className="flex flex-col items-center md:items-start">
            <div className="mb-4 flex items-center justify-center w-full md:w-auto">
              <div className="flex items-center justify-center">
                <Logo className="w-12 h-12" showText={true} textClassName="text-white" />
              </div>
            </div>
            <p className="text-gray-400 text-sm">
              Your trusted online marketplace for quality products and exceptional service.
            </p>
          </div>

          {/* Navigation */}
          <div>
            <h3 className="font-semibold mb-4">Navigation</h3>
            <ul className="space-y-2 text-sm text-gray-400">
              <li>
                <Link href="/" className="hover:text-white transition-colors">
                  Home
                </Link>
              </li>
              <li>
                <Link href="/about" className="hover:text-white transition-colors">
                  About Us
                </Link>
              </li>
              <li>
                <Link href="/contact" className="hover:text-white transition-colors">
                  Contact
                </Link>
              </li>
            </ul>
          </div>

          {/* Contact Info */}
          <div>
            <h3 className="font-semibold mb-4">Contact</h3>
            <ul className="space-y-2 text-sm text-gray-400">
              <li>
                <a href="mailto:info@tamigoods.eu" className="hover:text-white transition-colors">
                  info@tamigoods.eu
                </a>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="border-t border-gray-800 pt-8">
          <div className="flex flex-col md:flex-row items-center justify-center gap-4">
            <p className="text-sm text-gray-400">
              © {new Date().getFullYear()} TamiGoods. All rights reserved.
            </p>
          </div>
        </div>
      </div>
    </footer>
  )
}
