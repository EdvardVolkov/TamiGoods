export const metadata = {
  title: 'About Us - TamiGoods',
  description: 'Learn more about TamiGoods and our mission',
}

export default function About() {
  return (
    <div className="bg-gray-50 min-h-screen">
      {/* Hero Section */}
      <section className="bg-gradient-to-br from-primary-600 via-primary-500 to-primary-700 text-white py-16 px-4">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-4xl md:text-6xl font-bold mb-4">
            About TamiGoods
          </h1>
          <p className="text-xl text-primary-100">
            Your trusted online marketplace
          </p>
        </div>
      </section>

      {/* Main Content */}
      <section className="py-16 px-4">
        <div className="max-w-4xl mx-auto">
          <div className="bg-white rounded-xl shadow-lg p-8 md:p-12 space-y-8">
            <div>
              <h2 className="text-3xl font-bold text-gray-900 mb-4">
                Our Mission
              </h2>
              <p className="text-lg text-gray-700 leading-relaxed">
                At TamiGoods, we are committed to providing a seamless and enjoyable online shopping experience. 
                Our mission is to connect customers with quality products while maintaining the highest standards 
                of service and reliability.
              </p>
            </div>

            <div>
              <h2 className="text-3xl font-bold text-gray-900 mb-4">
                What We Offer
              </h2>
              <p className="text-lg text-gray-700 leading-relaxed mb-4">
                TamiGoods is your one-stop destination for a wide variety of products across multiple categories. 
                Whether you're looking for the latest electronics, trendy fashion items, home essentials, 
                sports equipment, beauty products, or books, we've got you covered.
              </p>
              <p className="text-lg text-gray-700 leading-relaxed">
                We carefully curate our product selection to ensure that every item meets our quality standards. 
                Our goal is to make online shopping convenient, secure, and enjoyable for everyone.
              </p>
            </div>

            <div>
              <h2 className="text-3xl font-bold text-gray-900 mb-4">
                Our Values
              </h2>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
                <div className="text-center p-6 bg-primary-50 rounded-lg">
                  <div className="w-12 h-12 bg-primary-600 rounded-full flex items-center justify-center mx-auto mb-4">
                    <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                  </div>
                  <h3 className="font-bold text-gray-900 mb-2">Quality</h3>
                  <p className="text-gray-600 text-sm">We ensure every product meets our high standards</p>
                </div>
                <div className="text-center p-6 bg-primary-50 rounded-lg">
                  <div className="w-12 h-12 bg-primary-600 rounded-full flex items-center justify-center mx-auto mb-4">
                    <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                    </svg>
                  </div>
                  <h3 className="font-bold text-gray-900 mb-2">Customer First</h3>
                  <p className="text-gray-600 text-sm">Your satisfaction is our top priority</p>
                </div>
                <div className="text-center p-6 bg-primary-50 rounded-lg">
                  <div className="w-12 h-12 bg-primary-600 rounded-full flex items-center justify-center mx-auto mb-4">
                    <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                    </svg>
                  </div>
                  <h3 className="font-bold text-gray-900 mb-2">Trust</h3>
                  <p className="text-gray-600 text-sm">Secure transactions and reliable service</p>
                </div>
              </div>
            </div>

            <div>
              <h2 className="text-3xl font-bold text-gray-900 mb-4">
                Coming Soon
              </h2>
              <p className="text-lg text-gray-700 leading-relaxed">
                We're currently working hard to bring you an exceptional shopping experience. 
                Stay tuned for our official launch, where you'll be able to browse and purchase 
                from our extensive product catalog.
              </p>
            </div>
          </div>
        </div>
      </section>
    </div>
  )
}


